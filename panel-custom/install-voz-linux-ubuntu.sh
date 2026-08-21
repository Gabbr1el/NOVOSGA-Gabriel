#!/usr/bin/env bash

set -euo pipefail

VOICE_NAME='Letícia-F123'
RHVOICE_VM='/snap/bin/rhvoice.vm'
RHVOICE_TEST='/snap/bin/rhvoice.test'
RHVOICE_SPD_MODULE='/snap/rhvoice/current/bin/sd_rhvoice'
SPD_MODULE_DIR='/usr/lib/speech-dispatcher-modules'
SPD_MODULE_LINK="${SPD_MODULE_DIR}/sd_rhvoice"
SPD_SYSTEM_CONF='/etc/speech-dispatcher/speechd.conf'
SPD_MODULE_CONF='/etc/speech-dispatcher/modules/rhvoice.conf'
SPD_USER_CONF="${HOME}/.config/speech-dispatcher/speechd.conf"

log()  { printf '\n==> %s\n' "$*"; }
warn() { printf '\n[AVISO] %s\n' "$*" >&2; }
fail() { printf '\n[ERRO] %s\n' "$*" >&2; exit 1; }

configure_speechd_conf() {
  local file="$1"
  local mode="$2" # system | user
  local tmp

  [[ -f "$file" ]] || return 0

  tmp="$(mktemp)"

  awk '
    BEGIN { module_done=0; default_done=0 }

    /^[[:space:]]*#[[:space:]]*AddModule[[:space:]]+"rhvoice"[[:space:]]+"sd_rhvoice"/ {
      if (!module_done) {
        print "AddModule \"rhvoice\" \"sd_rhvoice\" \"rhvoice.conf\""
        module_done=1
      }
      next
    }

    /^[[:space:]]*AddModule[[:space:]]+"rhvoice"[[:space:]]+"sd_rhvoice"/ {
      if (!module_done) {
        print "AddModule \"rhvoice\" \"sd_rhvoice\" \"rhvoice.conf\""
        module_done=1
      }
      next
    }

    /^[[:space:]]*DefaultModule[[:space:]]+/ {
      if (!default_done) {
        print "DefaultModule rhvoice"
        default_done=1
      }
      next
    }

    { print }

    END {
      if (!module_done)
        print "AddModule \"rhvoice\" \"sd_rhvoice\" \"rhvoice.conf\""
      if (!default_done)
        print "DefaultModule rhvoice"
    }
  ' "$file" > "$tmp"

  if [[ "$mode" == 'system' ]]; then
    sudo install -m 0644 "$tmp" "$file"
  else
    install -m 0644 "$tmp" "$file"
  fi

  rm -f "$tmp"
}

log 'Verificando Snap...'
if ! command -v snap >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y snapd
fi

log 'Instalando/atualizando RHVoice...'
if snap list rhvoice >/dev/null 2>&1; then
  sudo snap refresh rhvoice || true
else
  # Tenta o canal padrão primeiro; se não existir versão estável, usa o canal edge oficial.
  sudo snap install rhvoice || sudo snap install --edge rhvoice
fi

[[ -x "$RHVOICE_VM" ]] || fail "rhvoice.vm não foi encontrado em ${RHVOICE_VM}."
[[ -x "$RHVOICE_TEST" ]] || fail "rhvoice.test não foi encontrado em ${RHVOICE_TEST}."

log 'Instalando a voz Letícia...'
sudo "$RHVOICE_VM" -i "$VOICE_NAME"

log 'Instalando Speech Dispatcher para integração com o navegador...'
sudo apt-get update
sudo apt-get install -y speech-dispatcher speech-dispatcher-audio-plugins libspeechd2

[[ -x "$RHVOICE_SPD_MODULE" ]] || fail "O módulo sd_rhvoice não foi encontrado em ${RHVOICE_SPD_MODULE}."

log 'Registrando RHVoice no Speech Dispatcher...'
sudo install -d -m 0755 "$SPD_MODULE_DIR"
sudo ln -sfn "$RHVOICE_SPD_MODULE" "$SPD_MODULE_LINK"

sudo install -d -m 0755 /etc/speech-dispatcher/modules
if [[ ! -f "$SPD_MODULE_CONF" ]]; then
  printf '%s\n' \
    '# Configuração do módulo RHVoice para Speech Dispatcher.' \
    '# A voz e os dados são fornecidos pelo RHVoice instalado via Snap.' \
    'Debug 0' \
    | sudo tee "$SPD_MODULE_CONF" >/dev/null
fi

[[ -f "$SPD_SYSTEM_CONF" ]] || fail "Arquivo ${SPD_SYSTEM_CONF} não encontrado após instalar speech-dispatcher."
configure_speechd_conf "$SPD_SYSTEM_CONF" system

# Se o usuário já possui uma configuração própria, ela prevalece sobre a global.
# Por isso aplicamos a mesma integração nela também.
if [[ -f "$SPD_USER_CONF" ]]; then
  log 'Aplicando RHVoice também à configuração de usuário do Speech Dispatcher...'
  configure_speechd_conf "$SPD_USER_CONF" user
fi

log 'Reiniciando Speech Dispatcher da sessão atual...'
pkill -u "$(id -u)" -x speech-dispatcher >/dev/null 2>&1 || true
sleep 1
speech-dispatcher -a >/dev/null 2>&1 || true
sleep 1

log 'Testando RHVoice diretamente...'
printf '%s\n' 'Olá, a voz Letícia foi instalada.' | "$RHVOICE_TEST" || true

log 'Verificando se o Speech Dispatcher enxerga as vozes RHVoice...'
VOICE_LIST="$(spd-say -L 2>/dev/null || true)"
printf '%s\n' "$VOICE_LIST"

if printf '%s\n' "$VOICE_LIST" | grep -Eqi 'Let[ií]cia|F123'; then
  printf '\nOK: Letícia está visível no Speech Dispatcher.\n'
else
  warn 'O RHVoice foi configurado, mas o nome Letícia/F123 não apareceu em spd-say -L. Feche o Firefox completamente, abra novamente e teste. Se continuar ausente, rode: spd-say -L'
fi

# Firefox nativo/DEB consegue usar o Speech Dispatcher. As versões Snap/Flatpak
# podem bloquear esse acesso por sandbox.
if command -v firefox >/dev/null 2>&1; then
  FIREFOX_BIN="$(readlink -f "$(command -v firefox)" 2>/dev/null || command -v firefox)"
  if [[ "$FIREFOX_BIN" == /snap/* ]] || snap list firefox >/dev/null 2>&1; then
    warn 'Foi detectado Firefox via Snap. A sandbox do Firefox Snap pode impedir o acesso ao Speech Dispatcher. Prefira a versão nativa/DEB do Firefox para o painel.'
  fi
fi

if command -v flatpak >/dev/null 2>&1 && flatpak info org.mozilla.firefox >/dev/null 2>&1; then
  warn 'Foi detectado Firefox via Flatpak. A sandbox pode impedir o acesso ao Speech Dispatcher. Prefira a versão nativa/DEB do Firefox para o painel.'
fi

printf '\nInstalação concluída.\n'
printf '%s\n' 'Feche TODAS as janelas do Firefox e abra o navegador normalmente novamente.'
printf '%s\n' 'Não é necessário usar um comando especial para iniciar o navegador.'
