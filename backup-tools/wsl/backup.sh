#!/usr/bin/env bash
set -Eeuo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$BASE_DIR/backup.env"

if [[ ! -f "$CONFIG" ]]; then
    echo "ERRO: arquivo de configuracao nao encontrado: $CONFIG" >&2
    exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG"

: "${SERVICO_MYSQL:=mysqldb}"
: "${USER_MYSQL:?USER_MYSQL nao configurado}"
: "${SENHA_MYSQL:?SENHA_MYSQL nao configurada}"
: "${BANCO_MYSQL:?BANCO_MYSQL nao configurado}"
: "${PASTA_LOCAL:?PASTA_LOCAL nao configurada}"
: "${MAX_BACKUPS:=7}"
: "${COMPOSE_PROJECT:=}"

if ! command -v docker >/dev/null 2>&1; then
    echo "ERRO: comando docker nao encontrado no WSL." >&2
    exit 1
fi

# Detecta o container pelo NOME DO SERVICO do Docker Compose, nao pelo nome
# fisico do container. Assim nomes como projeto-a-mysqldb-1 ou
# outro-projeto-mysqldb-1 nao exigem alteracao no script.
FILTROS=(--filter "label=com.docker.compose.service=$SERVICO_MYSQL")
if [[ -n "$COMPOSE_PROJECT" ]]; then
    FILTROS+=(--filter "label=com.docker.compose.project=$COMPOSE_PROJECT")
fi

mapfile -t CONTAINERS_MYSQL < <(docker ps "${FILTROS[@]}" --format '{{.ID}}')

if (( ${#CONTAINERS_MYSQL[@]} == 0 )); then
    echo "ERRO: nenhum container Docker Compose em execucao foi encontrado para o servico '$SERVICO_MYSQL'." >&2
    echo "Confira com: docker ps --filter label=com.docker.compose.service=$SERVICO_MYSQL" >&2
    exit 1
fi

if (( ${#CONTAINERS_MYSQL[@]} > 1 )); then
    echo "ERRO: mais de um container em execucao usa o servico '$SERVICO_MYSQL'." >&2
    echo "Containers encontrados:" >&2
    docker ps "${FILTROS[@]}" --format '  {{.Names}}  (projeto={{.Label "com.docker.compose.project"}})' >&2
    echo "Defina COMPOSE_PROJECT em backup.env para selecionar o projeto correto." >&2
    exit 1
fi

CONTAINER_MYSQL="${CONTAINERS_MYSQL[0]}"
CONTAINER_NOME="$(docker inspect -f '{{.Name}}' "$CONTAINER_MYSQL" | sed 's#^/##')"

mkdir -p "$PASTA_LOCAL"

DATA="$(date +'%Y%m%d_%H%M%S')"
NOME_ARQUIVO="backup_${DATA}.sql"
ARQUIVO_LOCAL="$PASTA_LOCAL/$NOME_ARQUIVO"
ARQUIVO_TEMP="$ARQUIVO_LOCAL.part"

rm -f -- "$ARQUIVO_TEMP"

cleanup() {
    rm -f -- "$ARQUIVO_TEMP" 2>/dev/null || true
}
trap cleanup ERR INT TERM

echo "======================================"
echo "Backup NovoSGA"
echo "Data: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Banco: $BANCO_MYSQL"
echo "Servico Compose: $SERVICO_MYSQL"
echo "Container detectado: $CONTAINER_NOME"
echo "======================================"
echo

echo "[1/3] Gerando dump MySQL..."

docker exec \
    -e MYSQL_PWD="$SENHA_MYSQL" \
    "$CONTAINER_MYSQL" \
    mysqldump \
    --single-transaction \
    --quick \
    --hex-blob \
    --no-tablespaces \
    --default-character-set=utf8mb4 \
    -u "$USER_MYSQL" \
    "$BANCO_MYSQL" \
    > "$ARQUIVO_TEMP"

if [[ ! -s "$ARQUIVO_TEMP" ]]; then
    echo "ERRO: o arquivo de backup ficou vazio." >&2
    exit 1
fi

if ! tail -n 20 "$ARQUIVO_TEMP" | grep -q -- '-- Dump completed on '; then
    echo "ERRO: o dump terminou sem o marcador de conclusao esperado." >&2
    exit 1
fi

mv -- "$ARQUIVO_TEMP" "$ARQUIVO_LOCAL"
trap - ERR INT TERM

echo "[2/3] Backup criado: $ARQUIVO_LOCAL"

echo "[3/3] Mantendo apenas os $MAX_BACKUPS backups locais mais recentes..."

find "$PASTA_LOCAL" \
    -maxdepth 1 \
    -type f \
    -name 'backup_*.sql' \
    -printf '%T@ %p\n' \
    | sort -nr \
    | tail -n "+$((MAX_BACKUPS + 1))" \
    | cut -d' ' -f2- \
    | while IFS= read -r ARQUIVO_ANTIGO; do
        [[ -n "$ARQUIVO_ANTIGO" ]] && rm -f -- "$ARQUIVO_ANTIGO"
      done

echo
echo "BACKUP CONCLUIDO COM SUCESSO"
echo "BACKUP_PATH=$ARQUIVO_LOCAL"
echo "BACKUP_NAME=$NOME_ARQUIVO"
