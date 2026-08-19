import path from 'node:path';

const DATABASE_PATTERN = /^[A-Za-z0-9_]{1,64}$/;
const SQL_EXTENSIONS = new Set(['.sql', '.bak']);
const BINLOG_EXTENSIONS = new Set(['.binlog', '.bin']);
const MIME_TYPES = new Set([
  'application/octet-stream',
  'application/sql',
  'application/x-sql',
  'text/plain',
  'text/x-sql'
]);

export function validateDatabaseName(name) {
  return DATABASE_PATTERN.test(name || '');
}

export function validateUploadMetadata(filename, mimeType) {
  const safeName = path.basename(filename || '');
  const extension = path.extname(safeName).toLowerCase();
  const numberedBinlog = /^mysql-bin\.\d{6,}$/i.test(safeName);
  if (!SQL_EXTENSIONS.has(extension) && !BINLOG_EXTENSIONS.has(extension) && !numberedBinlog) {
    return { valid: false, error: 'Extensão não permitida. Use .sql, .bak, .bin, .binlog ou mysql-bin.NNNNNN.' };
  }
  if (!MIME_TYPES.has((mimeType || '').toLowerCase())) {
    return { valid: false, error: 'Tipo MIME não permitido.' };
  }
  return { valid: true, safeName, extension, numberedBinlog };
}

export function classifyContent(buffer, metadata) {
  if (buffer.length >= 4 && buffer.subarray(0, 4).equals(Buffer.from([0xfe, 0x62, 0x69, 0x6e]))) {
    if (!BINLOG_EXTENSIONS.has(metadata.extension) && !metadata.numberedBinlog) {
      throw new Error('O conteúdo é um binlog, mas a extensão não corresponde a um log binário permitido.');
    }
    return 'binlog';
  }

  if (!SQL_EXTENSIONS.has(metadata.extension)) {
    throw new Error('O arquivo não possui a assinatura de um log binário MySQL.');
  }

  const sample = buffer.toString('utf8').replace(/^\uFEFF/, '');
  const printable = [...buffer].filter((byte) => byte === 9 || byte === 10 || byte === 13 || (byte >= 32 && byte <= 126) || byte >= 0xc2).length;
  const looksTextual = buffer.length > 0 && printable / buffer.length >= 0.85;
  const hasSqlToken = /(^|\s|;)(--|#|\/\*|CREATE|INSERT|REPLACE|DROP|ALTER|SET|USE|LOCK|UNLOCK|START|BEGIN|COMMIT|DELIMITER)\b/i.test(sample);
  if (!looksTextual || !hasSqlToken) {
    throw new Error('O arquivo .sql/.bak não parece conter um dump SQL textual. Backups físicos não são suportados.');
  }
  return 'sql';
}
