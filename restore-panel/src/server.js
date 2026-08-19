import express from 'express';
import helmet from 'helmet';
import { config } from './config.js';
import { cleanupJob, createJobDirectory, executeRestore, receiveUpload } from './restore.js';
import { createSecurity } from './security.js';

const app = express();
const security = createSecurity(config);
let restoreInProgress = false;

app.disable('x-powered-by');
app.use(helmet({ contentSecurityPolicy: { directives: { defaultSrc: ["'self'"], scriptSrc: ["'self'"], styleSrc: ["'self'"], imgSrc: ["'self'", 'data:'], connectSrc: ["'self'"], objectSrc: ["'none'"], frameAncestors: ["'none'"] } } }));
app.use(express.json({ limit: '4kb' }));
app.use(express.static('public', { index: 'index.html', maxAge: '1h', etag: true }));

app.get('/health', (_req, res) => res.json({ status: 'ok', restoring: restoreInProgress }));
app.post('/api/login', security.login);
app.post('/api/logout', security.requireAuth, security.logout);
app.get('/api/session', security.requireAuth, (req, res) => {
  res.json({ authenticated: true, csrfToken: security.csrfFor(req.sessionToken), restoring: restoreInProgress });
});

app.post('/api/restore', security.requireAuth, security.requireCsrf, async (req, res) => {
  if (restoreInProgress) return res.status(409).json({ error: 'Já existe uma restauração em andamento.' });
  restoreInProgress = true;
  let jobDir;
  try {
    jobDir = await createJobDirectory(config.tempRoot);
    const upload = await receiveUpload(req, jobDir, config.maxUploadBytes);
    await executeRestore(upload, jobDir, config);
    res.json({ success: true, message: `Restauração de ${upload.originalName} concluída no banco ${upload.database}.`, type: upload.kind });
  } catch (error) {
    console.error(`[restore] ${error.message}`);
    if (!res.headersSent) res.status(400).json({ error: error.message });
  } finally {
    await cleanupJob(jobDir).catch((error) => console.error(`[cleanup] ${error.message}`));
    restoreInProgress = false;
  }
});

app.use('/api', (_req, res) => res.status(404).json({ error: 'Endpoint não encontrado.' }));
app.use((error, _req, res, _next) => {
  console.error(`[server] ${error.message}`);
  res.status(400).json({ error: 'Requisição inválida.' });
});

const server = app.listen(config.port, '0.0.0.0', () => {
  console.log(`Painel de restauração ouvindo na porta ${config.port}`);
});

function shutdown() {
  server.close(() => process.exit(0));
  setTimeout(() => process.exit(1), 10_000).unref();
}
process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);
