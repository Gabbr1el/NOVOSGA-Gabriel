import crypto from 'node:crypto';

const COOKIE_NAME = 'restore_session';

function safeEqualText(left, right) {
  const a = Buffer.from(String(left));
  const b = Buffer.from(String(right));
  return a.length === b.length && crypto.timingSafeEqual(a, b);
}

function hmac(value, secret) {
  return crypto.createHmac('sha256', secret).update(value).digest('base64url');
}

function parseCookies(header = '') {
  return Object.fromEntries(header.split(';').map((item) => {
    const index = item.indexOf('=');
    if (index < 0) return ['', ''];
    return [item.slice(0, index).trim(), decodeURIComponent(item.slice(index + 1).trim())];
  }).filter(([key]) => key));
}

export function createSecurity(config) {
  const attempts = new Map();

  function issueSession(res) {
    const expiresAt = Date.now() + config.sessionTtlSeconds * 1000;
    const payload = `${expiresAt}.${crypto.randomBytes(24).toString('base64url')}`;
    const token = `${payload}.${hmac(payload, config.sessionSecret)}`;
    res.cookie(COOKIE_NAME, token, {
      httpOnly: true,
      sameSite: 'strict',
      secure: config.secureCookie,
      maxAge: config.sessionTtlSeconds * 1000,
      path: '/'
    });
    return token;
  }

  function getToken(req) {
    const token = parseCookies(req.headers.cookie)[COOKIE_NAME];
    if (!token) return null;
    const pieces = token.split('.');
    if (pieces.length !== 3) return null;
    const payload = `${pieces[0]}.${pieces[1]}`;
    if (!safeEqualText(pieces[2], hmac(payload, config.sessionSecret))) return null;
    if (!Number.isFinite(Number(pieces[0])) || Number(pieces[0]) <= Date.now()) return null;
    return token;
  }

  function csrfFor(token) {
    return hmac(`csrf:${token}`, config.sessionSecret);
  }

  function requireAuth(req, res, next) {
    const token = getToken(req);
    if (!token) return res.status(401).json({ error: 'Autenticação necessária.' });
    req.sessionToken = token;
    next();
  }

  function requireCsrf(req, res, next) {
    const supplied = req.get('x-csrf-token') || '';
    if (!safeEqualText(supplied, csrfFor(req.sessionToken))) {
      return res.status(403).json({ error: 'Token de segurança inválido. Atualize a página.' });
    }
    next();
  }

  function login(req, res) {
    const ip = req.socket.remoteAddress || 'unknown';
    const now = Date.now();
    const state = attempts.get(ip) || { count: 0, since: now };
    if (now - state.since > 15 * 60_000) {
      state.count = 0;
      state.since = now;
    }
    if (state.count >= 5) {
      return res.status(429).json({ error: 'Muitas tentativas. Aguarde 15 minutos.' });
    }
    if (!safeEqualText(req.body?.password || '', config.adminPassword)) {
      state.count += 1;
      attempts.set(ip, state);
      return res.status(401).json({ error: 'Senha incorreta.' });
    }
    attempts.delete(ip);
    const token = issueSession(res);
    return res.json({ authenticated: true, csrfToken: csrfFor(token) });
  }

  function logout(req, res) {
    res.clearCookie(COOKIE_NAME, { path: '/', sameSite: 'strict', secure: config.secureCookie });
    res.status(204).end();
  }

  return { requireAuth, requireCsrf, login, logout, getToken, csrfFor };
}
