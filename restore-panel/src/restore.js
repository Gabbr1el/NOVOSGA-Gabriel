import Busboy from 'busboy';
import crypto from 'node:crypto';
import { createReadStream, createWriteStream } from 'node:fs';
import { mkdtemp, open, rm } from 'node:fs/promises';
import path from 'node:path';
import { pipeline } from 'node:stream/promises';
import { spawn } from 'node:child_process';
import { classifyContent, validateDatabaseName, validateUploadMetadata } from './validation.js';

const STDERR_LIMIT = 16 * 1024;

function appendTail(current, chunk) {
  const combined = Buffer.concat([current, chunk]);
  return combined.length > STDERR_LIMIT ? combined.subarray(combined.length - STDERR_LIMIT) : combined;
}

async function sniff(filePath) {
  const handle = await open(filePath, 'r');
  try {
    const buffer = Buffer.alloc(64 * 1024);
    const { bytesRead } = await handle.read(buffer, 0, buffer.length, 0);
    return buffer.subarray(0, bytesRead);
  } finally {
    await handle.close();
  }
}

export async function receiveUpload(req, jobDir, maxUploadBytes) {
  let parser;
  try {
    parser = Busboy({
      headers: req.headers,
      limits: { files: 1, fields: 2, parts: 3, fileSize: maxUploadBytes, fieldSize: 128 }
    });
  } catch {
    throw new Error('Requisição multipart inválida.');
  }

  let database = '';
  let filePath = '';
  let metadata = null;
  let uploadError = null;
  let fileCount = 0;
  const writes = [];

  parser.on('field', (name, value) => {
    if (name === 'database') database = value.trim();
  });

  parser.on('file', (_name, stream, info) => {
    fileCount += 1;
    const checked = validateUploadMetadata(info.filename, info.mimeType);
    if (!checked.valid || fileCount > 1) {
      uploadError = checked.error || 'Envie somente um arquivo.';
      stream.resume();
      return;
    }
    metadata = checked;
    filePath = path.join(jobDir, `upload-${crypto.randomUUID()}`);
    const output = createWriteStream(filePath, { flags: 'wx', mode: 0o600 });
    stream.on('limit', () => { uploadError = `Arquivo excede o limite configurado de ${Math.floor(maxUploadBytes / 1024 / 1024)} MB.`; });
    writes.push(pipeline(stream, output).catch((error) => { uploadError ||= `Falha ao gravar upload: ${error.message}`; }));
  });

  const closed = new Promise((resolve, reject) => {
    parser.once('close', resolve);
    parser.once('error', reject);
    req.once('aborted', () => reject(new Error('Upload cancelado pelo cliente.')));
  });
  req.pipe(parser);
  await closed;
  await Promise.all(writes);

  if (uploadError) throw new Error(uploadError);
  if (!filePath || !metadata) throw new Error('Nenhum arquivo foi enviado.');
  if (!validateDatabaseName(database)) throw new Error('Nome do banco inválido. Use 1 a 64 letras, números ou underscore.');
  const kind = classifyContent(await sniff(filePath), metadata);
  return { database, filePath, kind, originalName: metadata.safeName };
}

function optionValue(value) {
  return `"${String(value).replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', '\\n').replaceAll('\r', '\\r')}"`;
}

async function writeCredentials(jobDir, db) {
  const file = path.join(jobDir, 'mysql.cnf');
  const content = `[client]\nhost=${optionValue(db.host)}\nport=${db.port}\nuser=${optionValue(db.user)}\npassword=${optionValue(db.password)}\nprotocol=TCP\n`;
  await (await import('node:fs/promises')).writeFile(file, content, { mode: 0o600, flag: 'wx' });
  return file;
}

function waitForProcess(child, label) {
  let stderr = Buffer.alloc(0);
  child.stderr.on('data', (chunk) => { stderr = appendTail(stderr, chunk); });
  return new Promise((resolve, reject) => {
    child.once('error', (error) => reject(new Error(`${label} não pôde iniciar: ${error.message}`)));
    child.once('close', (code, signal) => {
      if (code === 0) return resolve();
      const details = stderr.toString('utf8').trim();
      reject(new Error(`${label} falhou (${signal || `código ${code}`})${details ? `: ${details}` : ''}`));
    });
  });
}

function mysqlArgs(credentialsFile, database, db) {
  const args = [`--defaults-extra-file=${credentialsFile}`, '--default-character-set=utf8mb4', '--binary-mode'];
  if (db.sslMode) args.push(`--ssl-mode=${db.sslMode}`);
  args.push(database);
  return args;
}

async function createDatabase(credentialsFile, database, db) {
  const args = [`--defaults-extra-file=${credentialsFile}`];
  if (db.sslMode) args.push(`--ssl-mode=${db.sslMode}`);
  args.push('--execute', `CREATE DATABASE IF NOT EXISTS \`${database}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`);
  const child = spawn('mysql', args, { stdio: ['ignore', 'ignore', 'pipe'] });
  await waitForProcess(child, 'Criação do banco');
}

export async function executeRestore(upload, jobDir, config) {
  const credentialsFile = await writeCredentials(jobDir, config.db);
  if (config.db.autoCreate) await createDatabase(credentialsFile, upload.database, config.db);

  const mysql = spawn('mysql', mysqlArgs(credentialsFile, upload.database, config.db), {
    stdio: ['pipe', 'ignore', 'pipe']
  });
  const processes = [mysql];
  const timer = setTimeout(() => processes.forEach((child) => child.kill('SIGTERM')), config.restoreTimeoutMs);

  try {
    if (upload.kind === 'sql') {
      await Promise.all([
        pipeline(createReadStream(upload.filePath), mysql.stdin),
        waitForProcess(mysql, 'Cliente MySQL')
      ]);
    } else {
      const command = process.env.MYSQLBINLOG_BIN || 'mysqlbinlog';
      const binlog = spawn(command, ['--verify-binlog-checksum', upload.filePath], { stdio: ['ignore', 'pipe', 'pipe'] });
      processes.push(binlog);
      await Promise.all([
        pipeline(binlog.stdout, mysql.stdin),
        waitForProcess(binlog, 'mysqlbinlog'),
        waitForProcess(mysql, 'Cliente MySQL')
      ]);
    }
  } catch (error) {
    processes.forEach((child) => child.exitCode === null && child.kill('SIGTERM'));
    throw error;
  } finally {
    clearTimeout(timer);
  }
}

export async function createJobDirectory(tempRoot) {
  return mkdtemp(path.join(tempRoot, 'mysql-restore-'));
}

export async function cleanupJob(jobDir) {
  if (jobDir) await rm(jobDir, { recursive: true, force: true });
}
