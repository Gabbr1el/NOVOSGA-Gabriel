const state = {
  ultimoId: null,
  accessToken: null,
  refreshToken: null,
  expireAt: null,

  audioLiberado: false,
  pollingId: null,
  painelIniciado: false,
};

const audioAlerta = new Audio();
const audioTts = new Audio();

audioAlerta.preload = "auto";
audioTts.preload = "auto";

let configInicial = null;


/* =========================================================
   STORAGE
   ========================================================= */

function storageGet(key, fallback = null) {
  try {
    const raw = localStorage.getItem(`painel-web.v2.${key}`);
    return raw ? JSON.parse(raw) : fallback;
  } catch {
    return fallback;
  }
}

function storageSet(key, value) {
  try {
    localStorage.setItem(
      `painel-web.v2.${key}`,
      JSON.stringify(value)
    );
  } catch (erro) {
    console.warn(
      "Erro ao salvar no localStorage:",
      erro
    );
  }
}


/* =========================================================
   CONFIGURAÇÃO
   ========================================================= */

async function getConfig() {
  try {
    const resp = await fetch(
      `/config.json?v=${Date.now()}`,
      {
        cache: "no-store"
      }
    );

    if (!resp.ok) {
      throw new Error(
        `Erro ao carregar config.json: ${resp.status}`
      );
    }

    const config = await resp.json();

    const host =
      window.location.hostname;

    const protocol =
      window.location.protocol;

    /*
     * Se o painel abrir em:
     *
     * http://10.0.0.237:8082
     *
     * usa automaticamente:
     *
     * NovoSGA:
     * http://10.0.0.237:8080
     *
     * TTS:
     * http://10.0.0.237:5001
     */

    config.server =
      `${protocol}//${host}:8080`;

    config.ttsServer =
      `${protocol}//${host}:5001`;

    return config;

  } catch (erro) {
    console.error(
      "Falha ao carregar configuração:",
      erro
    );

    return null;
  }
}


/* =========================================================
   AUTENTICAÇÃO
   ========================================================= */

function isTokenValid() {
  const expireDate =
    storageGet("expire_date");

  if (
    !state.accessToken &&
    storageGet("access_token")
  ) {
    state.accessToken =
      storageGet("access_token");
  }

  if (
    !state.refreshToken &&
    storageGet("refresh_token")
  ) {
    state.refreshToken =
      storageGet("refresh_token");
  }

  if (
    !state.accessToken ||
    !expireDate
  ) {
    return false;
  }

  return (
    new Date(expireDate).getTime() >
    Date.now() + 60000
  );
}


async function loginComSenha(config) {
  const form =
    new URLSearchParams();

  form.append(
    "grant_type",
    "password"
  );

  form.append(
    "client_id",
    config.clientId
  );

  form.append(
    "client_secret",
    config.clientSecret
  );

  form.append(
    "username",
    config.username
  );

  form.append(
    "password",
    config.password
  );

  const resp = await fetch(
    `${config.server}/api/token`,
    {
      method: "POST",
      body: form,
    }
  );

  if (!resp.ok) {
    throw new Error(
      `Erro ao autenticar: ${resp.status}`
    );
  }

  return await resp.json();
}


async function renovarToken(config) {
  const refreshToken =
    state.refreshToken ||
    storageGet("refresh_token");

  if (!refreshToken) {
    return loginComSenha(config);
  }

  const form =
    new URLSearchParams();

  form.append(
    "grant_type",
    "refresh_token"
  );

  form.append(
    "client_id",
    config.clientId
  );

  form.append(
    "client_secret",
    config.clientSecret
  );

  form.append(
    "refresh_token",
    refreshToken
  );

  const resp = await fetch(
    `${config.server}/api/token`,
    {
      method: "POST",
      body: form,
    }
  );

  if (!resp.ok) {
    return loginComSenha(config);
  }

  return await resp.json();
}


async function garantirToken() {
  const config =
    await getConfig();

  if (!config) {
    mostrarErro(
      "Painel não configurado",
      "Configure server, unidade e credenciais."
    );

    return null;
  }

  if (isTokenValid()) {
    return state.accessToken;
  }

  const tokenData =
    await renovarToken(config);

  state.accessToken =
    tokenData.access_token;

  state.refreshToken =
    tokenData.refresh_token;

  const expireDate =
    new Date(
      Date.now() +
      tokenData.expires_in * 1000
    ).toISOString();

  storageSet(
    "access_token",
    state.accessToken
  );

  storageSet(
    "refresh_token",
    state.refreshToken
  );

  storageSet(
    "expire_date",
    expireDate
  );

  return state.accessToken;
}


/* =========================================================
   RELÓGIO
   ========================================================= */

function atualizarHora() {
  const elemento =
    document.getElementById("hora");

  if (!elemento) {
    return;
  }

  elemento.textContent =
    new Date().toLocaleTimeString(
      "pt-BR"
    );
}


/* =========================================================
   ABREVIAÇÃO DO NOME
   ========================================================= */

function abreviarNome(
  nome,
  limite = 20
) {
  if (!nome) {
    return "";
  }

  nome = nome.trim();

  if (nome.length <= limite) {
    return nome;
  }

  const partes =
    nome
      .split(" ")
      .filter(Boolean);

  if (partes.length <= 2) {
    return (
      nome.slice(
        0,
        limite - 3
      ) + "..."
    );
  }

  let resultado = nome;

  for (
    let i = partes.length - 1;
    i >= 1;
    i--
  ) {
    partes[i] =
      `${partes[i][0]}.`;

    resultado =
      partes.join(" ");

    if (
      resultado.length <= limite
    ) {
      return resultado;
    }
  }

  return (
    resultado.length <= limite
      ? resultado
      : resultado.slice(
          0,
          limite - 3
        ) + "..."
  );
}


/* =========================================================
   CARREGAR CHAMADAS
   ========================================================= */

async function carregarChamadas() {
  const config =
    await getConfig();

  if (!config) {
    mostrarErro(
      "Painel não configurado",
      "Abra as configurações primeiro."
    );

    return;
  }

  try {
    const token =
      await garantirToken();

    if (!token) {
      return;
    }

    const servicos =
      Array.isArray(
        config.services
      )
        ? config.services
            .map(Number)
            .filter(n => n > 0)
            .join(",")
        : "";

    const url =
      `${config.server}` +
      `/api/unidades/${config.unity}` +
      `/painel?servicos=${servicos}`;

    const resp =
      await fetch(
        url,
        {
          headers: {
            Authorization:
              `Bearer ${token}`,
          },
        }
      );

    if (
      resp.status === 401 ||
      resp.status === 403
    ) {
      storageSet(
        "access_token",
        null
      );

      state.accessToken = null;

      return;
    }

    if (!resp.ok) {
      console.error(
        "Erro API:",
        resp.status,
        await resp.text()
      );

      return;
    }

    const dados =
      await resp.json();

    if (
      !Array.isArray(dados) ||
      dados.length === 0
    ) {
      return;
    }

    const atual =
      dados[0];

    const nome =
      atual.nomeCliente ||
      (
        `${atual.siglaSenha}` +
        `${String(
          atual.numeroSenha
        ).padStart(3, "0")}`
      );

    const local =
      `${atual.local} ${atual.numeroLocal}`;

    const nomeElemento =
      document.getElementById(
        "nome"
      );

    const localElemento =
      document.getElementById(
        "local"
      );

    if (nomeElemento) {
      nomeElemento.textContent =
        nome;
    }

    if (localElemento) {
      localElemento.textContent =
        local;
    }

    montarHistorico(
      dados,
      atual
    );

    /*
     * Chamada nova.
     */
    if (
      atual.id !==
      state.ultimoId
    ) {
      state.ultimoId =
        atual.id;

      tocarAlerta(
        config.alert
      );

      setTimeout(
        () => {
          falar(
            nome,
            local,
            config
          );
        },
        2500
      );
    }

  } catch (erro) {
    console.error(erro);

    mostrarErro(
      "Erro de conexão",
      erro.message
    );
  }
}


/* =========================================================
   HISTÓRICO
   ========================================================= */

function montarHistorico(
  dados,
  atual
) {
  const lista =
    document.getElementById(
      "lista"
    );

  if (!lista) {
    return;
  }

  lista.innerHTML = "";

  if (
    !Array.isArray(dados) ||
    !atual
  ) {
    return;
  }


  function gerarChave(item) {
    if (!item) {
      return "";
    }

    const nome =
      item.nomeCliente || "";

    const sigla =
      item.siglaSenha || "";

    const numero =
      item.numeroSenha || "";

    const local =
      item.local || "";

    const numeroLocal =
      item.numeroLocal || "";

    return (
      `${nome}-` +
      `${sigla}-` +
      `${numero}-` +
      `${local}-` +
      `${numeroLocal}`
    );
  }


  const chaveAtual =
    gerarChave(atual);

  const chamadasJaMostradas =
    new Set();


  const historico =
    dados
      .filter(item => {
        if (!item) {
          return false;
        }

        const chaveItem =
          gerarChave(item);

        if (
          chaveItem ===
          chaveAtual
        ) {
          return false;
        }

        if (
          chamadasJaMostradas
            .has(chaveItem)
        ) {
          return false;
        }

        chamadasJaMostradas
          .add(chaveItem);

        return true;
      })
      .slice(0, 3);


  historico.forEach(
    item => {
      const nome =
        item.nomeCliente ||
        (
          `${item.siglaSenha || ""}` +
          `${String(
            item.numeroSenha || ""
          ).padStart(3, "0")}`
        );

      const local =
        `${item.local || ""} ` +
        `${item.numeroLocal || ""}`;

      const div =
        document.createElement(
          "div"
        );

      div.className =
        "item";


      const strong =
        document.createElement(
          "strong"
        );

      strong.textContent =
        abreviarNome(nome);


      const span =
        document.createElement(
          "span"
        );

      span.textContent =
        local;


      div.appendChild(
        strong
      );

      div.appendChild(
        span
      );

      lista.appendChild(
        div
      );
    }
  );
}


/* =========================================================
   REMOVER POPUP DO HTML
   ========================================================= */

function removerPopupSom(botao) {

  /*
   * Primeiro tenta encontrar pelo ID.
   */
  const popupPorId =
    document.getElementById(
      "popupSom"
    );

  if (popupPorId) {
    popupPorId.style.setProperty(
      "display",
      "none",
      "important"
    );

    popupPorId.remove();

    return;
  }


  /*
   * Depois tenta pela classe.
   */
  const popupPorClasse =
    document.querySelector(
      ".popup-som"
    );

  if (popupPorClasse) {
    popupPorClasse.style.setProperty(
      "display",
      "none",
      "important"
    );

    popupPorClasse.remove();

    return;
  }


  /*
   * Caso o popup tenha outro nome,
   * sobe pelos elementos pais até
   * encontrar o overlay position: fixed.
   */
  let elemento =
    botao.parentElement;

  while (
    elemento &&
    elemento !==
    document.body
  ) {
    const estilo =
      window.getComputedStyle(
        elemento
      );

    if (
      estilo.position ===
      "fixed"
    ) {
      elemento.style.setProperty(
        "display",
        "none",
        "important"
      );

      elemento.remove();

      return;
    }

    elemento =
      elemento.parentElement;
  }


  /*
   * Último fallback.
   */
  botao.style.display =
    "none";
}


/* =========================================================
   INICIAR CONSULTA DO PAINEL
   ========================================================= */

function iniciarConsultas() {
  if (
    state.painelIniciado
  ) {
    return;
  }

  state.painelIniciado =
    true;

  carregarChamadas();

  if (
    !state.pollingId
  ) {
    state.pollingId =
      setInterval(
        carregarChamadas,
        3000
      );
  }
}


/* =========================================================
   POPUP EXISTENTE DO INDEX.HTML
   ========================================================= */

async function configurarPopupAudio() {

  /*
   * ESTE APP.JS NÃO CRIA POPUP.
   *
   * Ele usa o botão que já existe
   * no index.html:
   *
   * btnAtivarSom
   */

  const botao =
    document.getElementById(
      "btnAtivarSom"
    );


  /*
   * Se por algum motivo não existir popup,
   * deixa o painel funcionar normalmente.
   */
  if (!botao) {
    console.warn(
      "btnAtivarSom não encontrado."
    );

    state.audioLiberado =
      true;

    iniciarConsultas();

    return;
  }


  /*
   * Carrega configuração ANTES
   * do usuário apertar OK.
   */
  try {
    configInicial =
      await getConfig();

    if (configInicial) {
      const ttsServer = (
        configInicial.ttsServer ||
        `${window.location.protocol}//${window.location.hostname}:5001`
      ).replace(/\/$/, "");


      const voz =
        configInicial.ttsVoice ||
        "letícia-f123";


      /*
       * Prepara o mesmo player
       * que será usado nas chamadas.
       */
      audioTts.src =
        `${ttsServer}/say` +
        `?text=${encodeURIComponent("ok")}` +
        `&voice=${encodeURIComponent(voz)}` +
        `&format=wav`;

      audioTts.load();


      /*
       * Também prepara o alerta
       * caso exista no config.
       */
      if (
        configInicial.alert
      ) {
        audioAlerta.src =
          `static/sound/alert/${configInicial.alert}`;

        audioAlerta.load();
      }
    }

  } catch (erro) {
    console.warn(
      "Erro ao preparar áudio:",
      erro
    );
  }


  /*
   * Deixa o botão selecionado
   * automaticamente no Fire Stick.
   */
  setTimeout(
    () => {
      try {
        botao.focus();
      } catch {}
    },
    150
  );


  let processando =
    false;


  function ativarAudio(
    event
  ) {
    if (event) {
      event.preventDefault();
      event.stopPropagation();
    }


    if (processando) {
      return;
    }

    processando =
      true;


    /*
     * PRIMEIRO:
     * libera estado do áudio.
     */
    state.audioLiberado =
      true;


    console.log(
      "OK pressionado."
    );


    /*
     * SEGUNDO:
     * REMOVE O POPUP IMEDIATAMENTE.
     *
     * Não espera áudio.
     * Não espera fetch.
     */
    removerPopupSom(
      botao
    );


    /*
     * Tenta liberar AudioContext.
     */
    try {
      const AudioContextClass =
        window.AudioContext ||
        window.webkitAudioContext;

      if (
        AudioContextClass
      ) {
        if (
          !window.painelAudioContext
        ) {
          window.painelAudioContext =
            new AudioContextClass();
        }

        if (
          window
            .painelAudioContext
            .state ===
          "suspended"
        ) {
          window
            .painelAudioContext
            .resume()
            .catch(() => {});
        }
      }

    } catch (erro) {
      console.warn(
        "AudioContext:",
        erro
      );
    }


    /*
     * TTS:
     *
     * play() é chamado DIRETAMENTE
     * durante o OK do usuário.
     */
    try {
      if (
        audioTts.src
      ) {
        audioTts.volume =
          0.01;

        const promessaTts =
          audioTts.play();

        if (
          promessaTts &&
          typeof promessaTts.then ===
          "function"
        ) {
          promessaTts
            .then(() => {
              setTimeout(
                () => {
                  try {
                    audioTts.pause();

                    audioTts.currentTime =
                      0;

                    audioTts.volume =
                      1;
                  } catch {}
                },
                200
              );
            })
            .catch(
              erro => {
                audioTts.volume =
                  1;

                console.warn(
                  "Teste TTS:",
                  erro
                );
              }
            );
        }
      }

    } catch (erro) {
      audioTts.volume =
        1;

      console.warn(
        "Erro TTS:",
        erro
      );
    }


    /*
     * Também tenta liberar o player
     * do alerta.
     */
    try {
      if (
        audioAlerta.src
      ) {
        audioAlerta.volume =
          0.01;

        const promessaAlerta =
          audioAlerta.play();

        if (
          promessaAlerta &&
          typeof promessaAlerta.then ===
          "function"
        ) {
          promessaAlerta
            .then(() => {
              setTimeout(
                () => {
                  try {
                    audioAlerta.pause();

                    audioAlerta.currentTime =
                      0;

                    audioAlerta.volume =
                      1;
                  } catch {}
                },
                150
              );
            })
            .catch(
              erro => {
                audioAlerta.volume =
                  1;

                console.warn(
                  "Teste alerta:",
                  erro
                );
              }
            );
        }
      }

    } catch (erro) {
      audioAlerta.volume =
        1;

      console.warn(
        "Erro alerta:",
        erro
      );
    }


    /*
     * TERCEIRO:
     * começa o painel.
     */
    iniciarConsultas();
  }


  /*
   * Clique normal.
   */
  botao.addEventListener(
    "click",
    ativarAudio
  );


  /*
   * Fire Stick / controle remoto.
   */
  botao.addEventListener(
    "keydown",
    event => {
      const codigo =
        event.keyCode ||
        event.which;

      if (
        event.key === "Enter" ||
        event.key === " " ||
        codigo === 13 ||
        codigo === 23
      ) {
        ativarAudio(
          event
        );
      }
    }
  );


  /*
   * Alguns Fire Stick enviam
   * o Enter para document em vez
   * do botão focado.
   */
  function controleGlobal(
    event
  ) {
    if (
      state.audioLiberado
    ) {
      document.removeEventListener(
        "keydown",
        controleGlobal,
        true
      );

      return;
    }

    const codigo =
      event.keyCode ||
      event.which;

    if (
      event.key === "Enter" ||
      codigo === 13 ||
      codigo === 23
    ) {
      ativarAudio(
        event
      );

      document.removeEventListener(
        "keydown",
        controleGlobal,
        true
      );
    }
  }


  document.addEventListener(
    "keydown",
    controleGlobal,
    true
  );
}


/* =========================================================
   SOM DE ALERTA
   ========================================================= */

function tocarAlerta(
  alerta
) {
  if (
    !alerta ||
    !state.audioLiberado
  ) {
    return;
  }

  try {
    audioAlerta.pause();

    try {
      audioAlerta.currentTime =
        0;
    } catch {}


    audioAlerta.volume =
      1;

    audioAlerta.src =
      `static/sound/alert/${alerta}`;

    audioAlerta.load();


    const promessa =
      audioAlerta.play();

    if (
      promessa &&
      typeof promessa.catch ===
      "function"
    ) {
      promessa.catch(
        erro => {
          console.warn(
            "Erro ao tocar alerta:",
            erro
          );
        }
      );
    }

  } catch (erro) {
    console.warn(
      "Erro no áudio de alerta:",
      erro
    );
  }
}


/* =========================================================
   NÚMERO POR EXTENSO
   ========================================================= */

function numeroPorExtenso(n) {
  n = Number(n);

  const unidades = [
    "zero",
    "uumm",
    "dois",
    "três",
    "quatro",
    "cinco",
    "seis",
    "sete",
    "oito",
    "nove"
  ];

  const especiais = [
    "dez",
    "onze",
    "doze",
    "treze",
    "quatorze",
    "quinze",
    "dezesseis",
    "dezessete",
    "dezoito",
    "dezenove"
  ];

  const dezenas = [
    "",
    "",
    "vinte",
    "trinta",
    "quarenta",
    "cinquenta",
    "sessenta",
    "setenta",
    "oitenta",
    "noventa"
  ];

  const centenas = [
    "",
    "cento",
    "duzentos",
    "trezentos",
    "quatrocentos",
    "quinhentos",
    "seiscentos",
    "setecentos",
    "oitocentos",
    "novecentos"
  ];


  function ate999(num) {
    if (num === 0) {
      return "";
    }

    if (num < 10) {
      return unidades[num];
    }

    if (num < 20) {
      return especiais[
        num - 10
      ];
    }

    if (num < 100) {
      const d =
        Math.floor(
          num / 10
        );

      const u =
        num % 10;

      return (
        dezenas[d] +
        (
          u
            ? ` e ${unidades[u]}`
            : ""
        )
      );
    }

    if (num === 100) {
      return "cem";
    }

    const c =
      Math.floor(
        num / 100
      );

    const resto =
      num % 100;

    return (
      centenas[c] +
      (
        resto
          ? ` e ${ate999(resto)}`
          : ""
      )
    );
  }


  if (n < 1000) {
    return ate999(n);
  }


  if (n < 1000000) {
    const milhares =
      Math.floor(
        n / 1000
      );

    const resto =
      n % 1000;

    let texto =
      milhares === 1
        ? "mil"
        : `${ate999(milhares)} mil`;

    if (resto) {
      texto +=
        resto < 100 ||
        resto % 100 === 0
          ? ` e ${ate999(resto)}`
          : ` ${ate999(resto)}`;
    }

    return texto;
  }

  return String(n);
}


/* =========================================================
   TTS
   ========================================================= */

function falar(
  nome,
  local,
  config
) {
  if (
    !state.audioLiberado
  ) {
    console.warn(
      "Áudio ainda não foi liberado."
    );

    return;
  }


  const localFalado =
    local.replace(
      /\s+(\d+)$/,
      (_, numero) => {
        const extenso =
          numeroPorExtenso(
            numero
          );

        return `, ${extenso}`;
      }
    );


  const texto =
    `${nome}. ` +
    `Por favor, dirigir-se a ${localFalado}.`;


  const ttsServer = (
    config.ttsServer ||
    `${window.location.protocol}//${window.location.hostname}:5001`
  ).replace(/\/$/, "");


  const voz =
    config.ttsVoice ||
    "letícia-f123";


  const url =
    `${ttsServer}/say` +
    `?text=${encodeURIComponent(texto)}` +
    `&voice=${encodeURIComponent(voz)}` +
    `&format=wav`;


  console.log(
    "Texto TTS:",
    texto
  );

  console.log(
    "URL TTS:",
    url
  );


  try {
    audioTts.pause();

    try {
      audioTts.currentTime =
        0;
    } catch {}


    audioTts.volume =
      1;

    audioTts.src =
      url;

    audioTts.load();


    const promessa =
      audioTts.play();


    if (
      promessa &&
      typeof promessa.catch ===
      "function"
    ) {
      promessa.catch(
        erro => {
          console.warn(
            "Erro ao tocar TTS:",
            erro
          );
        }
      );
    }

  } catch (erro) {
    console.warn(
      "Erro ao preparar TTS:",
      erro
    );
  }
}


/* =========================================================
   ERRO NA TELA
   ========================================================= */

function mostrarErro(
  titulo,
  subtitulo
) {
  const nome =
    document.getElementById(
      "nome"
    );

  const local =
    document.getElementById(
      "local"
    );

  if (nome) {
    nome.textContent =
      titulo;
  }

  if (local) {
    local.textContent =
      subtitulo;
  }
}


/* =========================================================
   INICIALIZAÇÃO
   ========================================================= */

function iniciarPainel() {

  atualizarHora();

  setInterval(
    atualizarHora,
    1000
  );


  /*
   * NÃO começa carregarChamadas
   * imediatamente.
   *
   * Primeiro aguarda o OK
   * do popup existente no index.html.
   */

  configurarPopupAudio();
}


if (
  document.readyState ===
  "loading"
) {
  document.addEventListener(
    "DOMContentLoaded",
    iniciarPainel
  );
} else {
  iniciarPainel();
}