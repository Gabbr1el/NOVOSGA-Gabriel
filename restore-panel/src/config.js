import os from 'node:os';

function integer(name, fallback, min, max) {
  const value = Number.parseInt(process.env[name] ?? String(fallback), 10);
  if (!Number.isInteger(value) || value < min || value > max) {
    throw new Error(`${name} deve ser um inteiro entre ${min} e ${max}`);
  }
  return value;
}

function required(name, minimumLength = 1) {
  const value = process.env[name];
  if (!value || value.length < minimumLength) {
    throw new Error(`${name} é obrigatório e deve possuir ao menos ${minimumLength} caracteres`);
  }
  return value;
}

const sslMode = (process.env.DB_SSL_MODE ?? '').toUpperCase();
if (sslMode && !['DISABLED', 'PREFERRED', 'REQUIRED', 'VERIFY_CA', 'VERIFY_IDENTITY'].includes(sslMode)) {
  throw new Error('DB_SSL_MODE inválido');
}

export const config = Object.freeze({
  port: integer('PORT', 8080, 1, 65535),
  adminPassword: required('ADMIN_PASSWORD', 12),
  sessionSecret: required('SESSION_SECRET', 32),
  secureCookie: process.env.SECURE_COOKIE === 'true',
  sessionTtlSeconds: integer('SESSION_TTL_SECONDS', 3600, 300, 86400),
  maxUploadBytes: integer('MAX_UPLOAD_MB', 2048, 1, 102400) * 1024 * 1024,
  restoreTimeoutMs: integer('RESTORE_TIMEOUT_SECONDS', 7200, 30, 86400) * 1000,
  tempRoot: process.env.TEMP_DIR || os.tmpdir(),
  db: {
    host: process.env.DB_HOST || 'mysql',
    port: integer('DB_PORT', 3306, 1, 65535),
    user: required('DB_USER'),
    password: required('DB_PASSWORD'),
    sslMode,
    autoCreate: process.env.DB_AUTO_CREATE === 'true'
  }
});
