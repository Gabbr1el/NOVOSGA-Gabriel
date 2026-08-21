const state = {
  ultimoId: null,
  accessToken: null,
  refreshToken: null,
  expireAt: null,
};

function storageGet(key, fallback = null) {
  try {
    const raw = localStorage.getItem(`painel-web.v2.${key}`);
    return raw ? JSON.parse(raw) : fallback;
  } catch {
    return fallback;
  }
}

function storageSet(key, value) {
  localStorage.setItem(`painel-web.v2.${key}`, JSON.stringify(value));
}

async function getConfig() {
  try {
    const resp = await fetch(`/config.json?v=${Date.now()}`, {
      cache: "no-store"
    });

    if (!resp.ok) {
      throw new Error(`Erro ao carregar config.json: ${resp.status}`);
    }

    const config = await resp.json();

    const host = window.location.hostname;

    config.server =
      `${window.location.protocol}//${host}:8080`;

    config.ttsServer =
      `${window.location.protocol}//${host}:5001`;

    return config;

  } catch (erro) {
    console.error("Falha ao carregar configuração:", erro);
    return null;
  }
}

function isTokenValid() {
  const expireDate = storageGet("expire_date");

  if (!state.accessToken && storageGet("access_token")) {
    state.accessToken = storageGet("access_token");
  }

  if (!state.refreshToken && storageGet("refresh_token")) {
    state.refreshToken = storageGet("refresh_token");
  }

  if (!state.accessToken || !expireDate) return false;

  return new Date(expireDate).getTime() > Date.now() + 60000;
}

async function loginComSenha(config) {
  const form = new URLSearchParams();

  form.append("grant_type", "password");
  form.append("client_id", config.clientId);
  form.append("client_secret", config.clientSecret);
  form.append("username", config.username);
  form.append("password", config.password);

  const resp = await fetch(`${config.server}/api/token`, {
    method: "POST",
    body: form,
  });

  if (!resp.ok) {
    throw new Error(`Erro ao autenticar: ${resp.status}`);
  }

  return await resp.json();
}

async function renovarToken(config) {
  const refreshToken = state.refreshToken || storageGet("refresh_token");

  if (!refreshToken) {
    return loginComSenha(config);
  }

  const form = new URLSearchParams();

  form.append("grant_type", "refresh_token");
  form.append("client_id", config.clientId);
  form.append("client_secret", config.clientSecret);
  form.append("refresh_token", refreshToken);

  const resp = await fetch(`${config.server}/api/token`, {
    method: "POST",
    body: form,
  });

  if (!resp.ok) {
    return loginComSenha(config);
  }

  return await resp.json();
}

async function garantirToken() {
  const config = await getConfig();

  if (!config) {
    mostrarErro("Painel não configurado", "Configure server, unidade e credenciais.");
    return null;
  }

  if (isTokenValid()) {
    return state.accessToken;
  }

  const tokenData = await renovarToken(config);

  state.accessToken = tokenData.access_token;
  state.refreshToken = tokenData.refresh_token;

  const expireDate = new Date(Date.now() + tokenData.expires_in * 1000).toISOString();

  storageSet("access_token", state.accessToken);
  storageSet("refresh_token", state.refreshToken);
  storageSet("expire_date", expireDate);

  return state.accessToken;
}

function atualizarHora() {
  document.getElementById("hora").textContent =
    new Date().toLocaleTimeString("pt-BR");
}
function abreviarNome(nome, limite = 20) {
  if (!nome) return "";

  nome = nome.trim();

  if (nome.length <= limite) {
    return nome;
  }

  const partes = nome.split(" ").filter(Boolean);

  if (partes.length <= 2) {
    return nome.slice(0, limite - 3) + "...";
  }

  let resultado = nome;

  for (let i = partes.length - 1; i >= 1; i--) {
    partes[i] = `${partes[i][0]}.`;
    resultado = partes.join(" ");

    if (resultado.length <= limite) {
      return resultado;
    }
  }

  return resultado.length <= limite
    ? resultado
    : resultado.slice(0, limite - 3) + "...";
}

async function carregarChamadas() {
  const config = await getConfig();

  if (!config) {
    mostrarErro("Painel não configurado", "Abra as configurações primeiro.");
    return;
  }

  try {
    const token = await garantirToken();
    if (!token) return;

    const servicos = Array.isArray(config.services)
      ? config.services.map(Number).filter(n => n > 0).join(",")
      : "";

    const url = `${config.server}/api/unidades/${config.unity}/painel?servicos=${servicos}`;

    const resp = await fetch(url, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    if (resp.status === 401 || resp.status === 403) {
      storageSet("access_token", null);
      state.accessToken = null;
      return;
    }

    if (!resp.ok) {
      console.error("Erro API:", resp.status, await resp.text());
      return;
    }

    const dados = await resp.json();

    if (!Array.isArray(dados) || dados.length === 0) return;

    const atual = dados[0];

    const nome = atual.nomeCliente ||
      `${atual.siglaSenha}${String(atual.numeroSenha).padStart(3, "0")}`;

    const local = `${atual.local} ${atual.numeroLocal}`;

    document.getElementById("nome").textContent = nome;
    document.getElementById("local").textContent = local;

    montarHistorico(dados, atual);

    if (atual.id !== state.ultimoId) {
      state.ultimoId = atual.id;
      tocarAlerta(config.alert);

      setTimeout(() => {
        falar(nome, local, config);
      }, 2500);
    }
  } catch (e) {
    console.error(e);
    mostrarErro("Erro de conexão", e.message);
  }
}

function montarHistorico(dados, atual) {
  const lista = document.getElementById("lista");
  lista.innerHTML = "";

  if (!Array.isArray(dados) || !atual) return;

  function gerarChave(item) {
    if (!item) return "";

    const nome = item.nomeCliente || "";
    const sigla = item.siglaSenha || "";
    const numero = item.numeroSenha || "";
    const local = item.local || "";
    const numeroLocal = item.numeroLocal || "";

    return `${nome}-${sigla}-${numero}-${local}-${numeroLocal}`;
  }

  const chaveAtual = gerarChave(atual);
  const chamadasJaMostradas = new Set();
  
  const historico = dados
  .filter(item => {
    if (!item) return false;
    
      const chaveItem = gerarChave(item);

      if (chaveItem === chaveAtual) {
        return false;
      }

      if (chamadasJaMostradas.has(chaveItem)) {
        return false;
      }
      
      chamadasJaMostradas.add(chaveItem);
      return true;
    })
    
    .slice(0, 3);
    historico.forEach(item => {
      const nome = item.nomeCliente ||
      `${item.siglaSenha || ""}${String(item.numeroSenha || "").padStart(3, "0")}`;

    const local = `${item.local || ""} ${item.numeroLocal || ""}`;

    const div = document.createElement("div");
    div.className = "item";
    div.innerHTML = `<strong>${abreviarNome(nome)}</strong><span>${local}</span>`;
    lista.appendChild(div);
  });
}

function tocarAlerta(alerta) {
  if (!alerta) return;

  const audio = new Audio(`static/sound/alert/${alerta}`);
  audio.play().catch(() => {});
  
}

function numeroPorExtenso(n) {
  n = Number(n);

  const unidades = [
    "zero", "uumm", "dois", "três", "quatro",
    "cinco", "seis", "sete", "oito", "nove"
  ];

  const especiais = [
    "dez", "onze", "doze", "treze", "quatorze",
    "quinze", "dezesseis", "dezessete",
    "dezoito", "dezenove"
  ];

  const dezenas = [
    "", "", "vinte", "trinta", "quarenta",
    "cinquenta", "sessenta", "setenta",
    "oitenta", "noventa"
  ];

  const centenas = [
    "", "cento", "duzentos", "trezentos",
    "quatrocentos", "quinhentos",
    "seiscentos", "setecentos",
    "oitocentos", "novecentos"
  ];

  function ate999(num) {
    if (num === 0) return "";

    if (num < 10) return unidades[num];

    if (num < 20) return especiais[num - 10];

    if (num < 100) {
      const d = Math.floor(num / 10);
      const u = num % 10;

      return dezenas[d] + (u ? ` e ${unidades[u]}` : "");
    }

    if (num === 100) return "cem";

    const c = Math.floor(num / 100);
    const resto = num % 100;

    return centenas[c] + (resto ? ` e ${ate999(resto)}` : "");
  }

  if (n < 1000) {
    return ate999(n);
  }

  if (n < 1000000) {
    const milhares = Math.floor(n / 1000);
    const resto = n % 1000;

    let texto =
      milhares === 1
        ? "mil"
        : `${ate999(milhares)} mil`;

    if (resto) {
      texto += resto < 100 || resto % 100 === 0
        ? ` e ${ate999(resto)}`
        : ` ${ate999(resto)}`;
    }

    return texto;
  }

  return String(n);
}


function falar(nome, local, config) {
  const localFalado = local.replace(
    /\s+(\d+)$/,
    (_, numero) => {
      const extenso = numeroPorExtenso(numero);

      return `, ${extenso}`;
    }
  );

  const texto =
    `${nome}. Por favor, dirigir-se a ${localFalado}.`;

  // Usa o configurado no config.json.
  // Se não existir, tenta o mesmo computador do painel na porta 5001.
  const ttsServer = (
    config.ttsServer ||
    `${window.location.protocol}//${window.location.hostname}:5001`
  ).replace(/\/$/, "");

  const voz = config.ttsVoice || "letícia-f123";

  const url =
    `${ttsServer}/say` +
    `?text=${encodeURIComponent(texto)}` +
    `&voice=${encodeURIComponent(voz)}` +
    `&format=wav`;

  const audio = new Audio(url);

  audio.play().catch((err) => {
    console.warn("Erro ao tocar TTS:", err);
  });
}

function mostrarErro(titulo, subtitulo) {
  document.getElementById("nome").textContent = titulo;
  document.getElementById("local").textContent = subtitulo;
}

setInterval(atualizarHora, 1000);
setInterval(carregarChamadas, 3000);

atualizarHora();
carregarChamadas();