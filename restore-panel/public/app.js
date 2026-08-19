const loginForm = document.querySelector('#login-form');
const restoreForm = document.querySelector('#restore-form');
const feedback = document.querySelector('#feedback');
const backup = document.querySelector('#backup');
const fileLabel = document.querySelector('#file-label');
const restoreButton = document.querySelector('#restore-button');
const spinner = document.querySelector('.spinner');
const buttonText = document.querySelector('.button-text');
let csrfToken = '';

function message(text, type = 'error') {
  feedback.textContent = text;
  feedback.className = `feedback ${type}`;
}

function authenticated(token) {
  csrfToken = token;
  loginForm.classList.add('hidden');
  restoreForm.classList.remove('hidden');
  feedback.classList.add('hidden');
}

async function jsonResponse(response) {
  const body = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(body.error || `Falha HTTP ${response.status}`);
  return body;
}

loginForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  const button = loginForm.querySelector('button');
  button.disabled = true;
  try {
    const response = await fetch('/api/login', { method:'POST', headers:{'content-type':'application/json'}, body:JSON.stringify({ password:loginForm.password.value }) });
    const body = await jsonResponse(response);
    loginForm.reset();
    authenticated(body.csrfToken);
  } catch (error) {
    message(error.message);
  } finally {
    button.disabled = false;
  }
});

backup.addEventListener('change', () => {
  const file = backup.files[0];
  fileLabel.textContent = file ? `${file.name} · ${(file.size / 1024 / 1024).toFixed(1)} MB` : 'Selecionar .sql, .bak ou binlog';
});

restoreForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  if (!confirm(`Restaurar o arquivo no banco "${restoreForm.database.value}"? Esta ação pode sobrescrever dados.`)) return;
  restoreButton.disabled = true;
  spinner.classList.remove('hidden');
  buttonText.textContent = 'Restaurando… não feche a página';
  feedback.classList.add('hidden');
  try {
    const data = new FormData();
    data.append('database', restoreForm.database.value);
    data.append('backup', backup.files[0]);
    const body = await jsonResponse(await fetch('/api/restore', { method:'POST', headers:{'x-csrf-token':csrfToken}, body:data }));
    message(body.message, 'success');
    restoreForm.reset();
    fileLabel.textContent = 'Selecionar .sql, .bak ou binlog';
  } catch (error) {
    message(error.message);
  } finally {
    restoreButton.disabled = false;
    spinner.classList.add('hidden');
    buttonText.textContent = 'Importar Banco de Dados';
  }
});

document.querySelector('#logout-button').addEventListener('click', async () => {
  await fetch('/api/logout', { method:'POST' }).catch(() => {});
  csrfToken = '';
  restoreForm.classList.add('hidden');
  loginForm.classList.remove('hidden');
  feedback.classList.add('hidden');
});

fetch('/api/session').then(jsonResponse).then((body) => authenticated(body.csrfToken)).catch(() => {});
