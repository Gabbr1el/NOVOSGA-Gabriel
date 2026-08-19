import test from 'node:test';
import assert from 'node:assert/strict';
import { classifyContent, validateDatabaseName, validateUploadMetadata } from '../src/validation.js';

test('aceita somente nomes seguros de banco', () => {
  assert.equal(validateDatabaseName('novosga2'), true);
  assert.equal(validateDatabaseName('db_teste_01'), true);
  assert.equal(validateDatabaseName('db; DROP DATABASE x'), false);
  assert.equal(validateDatabaseName('nome-com-hifen'), false);
});

test('valida extensão e MIME', () => {
  assert.equal(validateUploadMetadata('dump.sql', 'application/sql').valid, true);
  assert.equal(validateUploadMetadata('mysql-bin.000001', 'application/octet-stream').valid, true);
  assert.equal(validateUploadMetadata('shell.sh', 'text/plain').valid, false);
});

test('identifica SQL textual e binlog pela assinatura', () => {
  const sqlMeta = validateUploadMetadata('dump.bak', 'application/octet-stream');
  assert.equal(classifyContent(Buffer.from('-- MySQL dump\nCREATE TABLE teste (id INT);'), sqlMeta), 'sql');
  const binMeta = validateUploadMetadata('events.binlog', 'application/octet-stream');
  assert.equal(classifyContent(Buffer.from([0xfe, 0x62, 0x69, 0x6e, 0x00]), binMeta), 'binlog');
});

test('rejeita backup físico renomeado para .bak', () => {
  const meta = validateUploadMetadata('physical.bak', 'application/octet-stream');
  assert.throws(() => classifyContent(Buffer.from([0, 1, 2, 3, 4]), meta));
});
