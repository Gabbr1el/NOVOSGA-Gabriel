# Painel de restauração MySQL

Painel web minimalista e autenticado para aplicar dumps SQL textuais (`.sql` ou `.bak`) e logs binários (`.bin`, `.binlog` ou `mysql-bin.NNNNNN`) a um servidor MySQL. Upload e restauração usam streams; o arquivo e a credencial temporária são apagados ao final, inclusive em caso de erro.

## Estrutura

```text
mysql-restore-panel/
├── public/                 # interface responsiva, sem CDN
│   ├── app.js
│   ├── index.html
│   └── styles.css
├── src/
│   ├── config.js           # configuração e validação das variáveis
│   ├── restore.js          # upload, mysql e mysqlbinlog
│   ├── security.js         # sessão, CSRF e limite de login
│   ├── server.js           # API Express
│   └── validation.js       # extensão, MIME, banco e assinatura
├── test/validation.test.js
├── .dockerignore
├── .env.example
├── .gitignore
├── Dockerfile
├── docker-compose.yml
└── package.json
```

## Executar com o MySQL de exemplo

Requisitos: Docker Engine com o plugin Docker Compose.

```bash
cp .env.example .env
openssl rand -hex 32
```

Edite `.env`, coloque o valor gerado em `SESSION_SECRET` e defina senhas fortes diferentes. Depois:

```bash
docker compose config
docker compose up -d --build
docker compose ps
docker compose logs -f restore-panel
```

Abra `http://localhost:8080`. A porta está vinculada somente a `127.0.0.1`. Para acesso remoto, prefira VPN ou proxy reverso HTTPS; se for indispensável expor diretamente, troque o mapeamento por `${PANEL_PORT:-8080}:8080` e ative `SECURE_COOKIE=true` atrás de HTTPS.

## Conectar a um MySQL já existente

O nome em `DB_HOST` precisa ser resolvível dentro do container. Se o painel for adicionado ao mesmo `docker-compose.yml` do banco, use o nome do serviço, por exemplo `DB_HOST: mysqldb`. Remova do exemplo o serviço `mysql`, o `depends_on` correspondente, e coloque `restore-panel` na mesma rede do banco.

Para o NovoSGA do ZIP fornecido, o destino usual é:

```yaml
environment:
  DB_HOST: mysqldb
  DB_PORT: 3306
  DB_USER: ${RESTORE_DB_USER}
  DB_PASSWORD: ${RESTORE_DB_PASSWORD}
```

Não use a porta publicada do host (`3307`) quando os dois serviços estão na mesma rede Docker; internamente o MySQL atende em `3306`. O usuário precisa de privilégios suficientes para todos os comandos existentes no dump. Para `DB_AUTO_CREATE=true`, também precisa de `CREATE` global; mantenha `false` quando o banco já existe.

Para banco em outro host/IP, defina `DB_HOST` com esse endereço, remova o `depends_on`, e garanta rota/firewall e permissão MySQL para a origem do container.

## Formatos e comportamento

- `.sql` e `.bak`: precisam conter SQL textual. Um `.bak` físico, diretório de dados, arquivo de tablespace ou backup proprietário não pode ser importado pelo cliente `mysql` e é rejeitado.
- Binlog: precisa começar com a assinatura binária MySQL `fe 62 69 6e`. O backend executa `mysqlbinlog` e transmite a saída ao cliente `mysql`, sem shell.
- Binlogs podem conter `USE banco_original` ou tabelas qualificadas. O banco informado no painel é o banco padrão, mas não reescreve referências internas do log. Confira a origem antes de aplicar.
- O limite padrão é 2 GB, controlado por `MAX_UPLOAD_MB`. O `tmpfs` deve ser maior do que o arquivo; ajuste `TEMP_VOLUME_SIZE` junto.
- Só uma restauração é executada por vez. O timeout padrão é 2 horas.

## Segurança operacional

- `ADMIN_PASSWORD` (mínimo 12 caracteres) e `SESSION_SECRET` (mínimo 32) são obrigatórios.
- Sessão `HttpOnly`, `SameSite=Strict`, proteção CSRF, limite de tentativas de login, CSP/headers de segurança e validação de banco/arquivo estão ativos.
- A senha MySQL fica em um arquivo temporário modo `0600`, não na linha de comando; o diretório inteiro é removido no bloco de limpeza.
- O container roda como usuário sem privilégios, filesystem somente leitura, `cap_drop: ALL` e `/tmp` efêmero.
- Restrinja a porta por firewall/VPN. Para produção remota, use HTTPS e defina `SECURE_COOKIE=true`.
- Faça primeiro uma restauração de teste em banco descartável e mantenha uma cópia íntegra do backup original.

## Testes e diagnóstico

```bash
npm install
npm test
npm run check
docker compose build
curl http://127.0.0.1:8080/health
```

Erros do `mysql`/`mysqlbinlog` aparecem na interface de forma limitada e nos logs do container. O endpoint `/health` não expõe credenciais.
