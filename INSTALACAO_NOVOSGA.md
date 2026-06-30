# Instalação do NovoSGA (fork `Gabbr1el/NOVOSGA-Gabriel`, branch `Default-empty`)

> Repositório: https://github.com/Gabbr1el/NOVOSGA-Gabriel/tree/Default-empty
> Esse fork já roda em modo **standalone via Docker** (imagem `novosga/novosga:2.2-standalone`), então **não é necessário instalar PHP, Composer ou MySQL na máquina** — só Docker. Isso facilita pra rodar tanto no PC do PET-Saúde quanto em outra máquina depois.

---

## 0. Pré-requisitos

Instalar antes de qualquer coisa:

- **Git**
- **Docker** + **Docker Compose** (no Linux, o pacote `docker-compose-plugin`; no Windows/Mac, o Docker Desktop já vem com tudo)

Verificar se está tudo certo:

```bash
docker --version
docker compose version
```

### 🪟 No Windows: e o WSL2?

O Docker Desktop no Windows precisa do **WSL2** (Windows Subsystem for Linux) por baixo dos panos. Na maioria dos casos (Windows 10 atualizado ou Windows 11), **o próprio instalador do Docker Desktop baixa e configura o WSL2 automaticamente** — você só confirma o reinício do PC quando ele pedir, e não precisa fazer nada manual.

Se o Docker Desktop **não fizer isso sozinho** (der erro de "WSL2 not installed" ou travar na instalação), instale manualmente:

1. Abra o **PowerShell como Administrador** (botão direito → "Executar como administrador")
2. Rode:
   ```powershell
   wsl --install
   ```
3. Esse comando já baixa o WSL2 + uma distro Linux padrão (Ubuntu) e ativa os recursos do Windows necessários
4. **Reinicie o computador** quando pedir
5. Depois do reinício, instale o Docker Desktop normalmente

Caso o comando `wsl --install` dê erro (geralmente em Windows 10 com build muito antiga), atualize o Windows primeiro (Configurações → Windows Update) e tente de novo. Também é bom checar se a **virtualização está habilitada na BIOS/UEFI** da placa-mãe — sem isso, nem o WSL2 nem o Docker funcionam.

Para confirmar que o WSL2 está instalado e ativo:

```powershell
wsl --status
```

---

## 1. Clonar o repositório (branch certa)

```bash
git clone --branch Default-empty https://github.com/Gabbr1el/NOVOSGA-Gabriel.git
cd NOVOSGA-Gabriel
```

> O `--branch Default-empty` já garante que você vai cair direto na branch certa, sem precisar fazer `checkout` depois.

---

## 2. Onde configurar cada coisa (antes de subir o container)

Todas as configurações principais do ambiente estão centralizadas em **um único arquivo**: `compose.yaml`, na raiz do projeto.

### 📄 `compose.yaml` (raiz do projeto)

É aqui que você muda:

| O que mudar | Onde fica no arquivo |
|---|---|
| Senha do banco/admin | `DATABASE_URL`, `MYSQL_ROOT_PASSWORD`, `MYSQL_PASSWORD` (serviço `mysqldb`) |
| Usuário/senha do administrador do sistema | `NOVOSGA_ADMIN_USERNAME`, `NOVOSGA_ADMIN_PASSWORD` |
| Nome e código da unidade de saúde | `NOVOSGA_UNITY_NAME`, `NOVOSGA_UNITY_CODE` |
| Nomes das prioridades de atendimento | `NOVOSGA_PRIORITY_NAME`, `NOVOSGA_NOPRIORITY_NAME` e descrições |
| Porta de acesso ao site | `ports: "80:8080"` do serviço `novosga` (troque o `80` se já tiver algo usando essa porta) |
| Fuso horário | `TZ: 'America/Sao_Paulo'` (já está certo pra Bahia) |

> ⚠️ Esse fork **já vem com esses valores customizados** (ex: unidade "Secretaria de Saúde - HOME", senha `150769`). Pra unidade de saúde de vocês, é só editar esses campos com os dados reais antes do primeiro `docker compose up`.

### 📄 `panel-custom/config.json`

Configura o **painel de chamada de senha** (o painel que fica na TV/monitor da recepção):

```json
{
  "server": "http://localhost",
  "unity": 2,
  "services": [5],
  "alert": "ding-dong.wav",
  "speech": true,
  "username": "admin",
  "password": "123456",
  "clientId": "",
  "clientSecret": ""
}
```

- `server`: endereço do servidor NovoSGA (se for rodar em outro computador na rede, troque `localhost` pelo IP da máquina servidor, ex: `http://192.168.1.10`)
- `unity`: ID da unidade cadastrada no banco
- `services`: lista de IDs dos serviços/guichês que esse painel deve exibir
- `username`/`password`: credenciais usadas pelo painel pra se autenticar na API

### 📄 `novosga-custom/custom.css`

CSS customizado da interface principal (logo, cores, etc. da unidade de saúde). Editar aqui se quiser dar uma identidade visual pro sistema.

### 📄 `templates/` (pasta)

Templates Twig customizados (`base.html.twig`, `attendance-index.html.twig`, `security/login.html.twig`, `skeleton.html.twig`). Editar só se for alterar a estrutura visual das páginas — não é necessário pra instalação básica.

---

## 3. Subir os containers

Na raiz do projeto (onde está o `compose.yaml`):

```bash
docker compose up -d --build
```

- `-d`: roda em segundo plano (detached)
- `--build`: força o build da imagem a partir do `Dockerfile` (necessário na primeira vez, já que o `compose.yaml` referencia `build: .`)

Isso vai subir 4 serviços:

| Serviço | Função | Porta local |
|---|---|---|
| `novosga` | Aplicação principal (PHP/Symfony) | `80` |
| `mercure` | Hub de notificações em tempo real (atualização automática de senhas) | `3000` |
| `panel` | Painel de chamada (TV/monitor) | `8081` |
| `mysqldb` | Banco de dados MySQL | `3307` |

Acompanhar os logs (útil pra ver se algo deu erro):

```bash
docker compose logs -f
```

---

## 4. Instalar o banco de dados (primeira vez)

Depois que os containers estiverem de pé (espere ~10-20s pro MySQL inicializar), execute o instalador do NovoSGA **dentro do container**:

```bash
docker compose exec novosga php bin/console novosga:install
```

Esse comando roda as migrations e cria o usuário administrador com os dados que você colocou em `NOVOSGA_ADMIN_USERNAME` / `NOVOSGA_ADMIN_PASSWORD` no `compose.yaml`.

> Esse script corresponde ao `etc/setup.sh`, que faz exatamente essa chamada — ele só não é executado automaticamente no `compose.yaml` desse fork, por isso o passo manual.

---

## 5. Acessar o sistema

- **Sistema principal (admin/atendimento):** http://localhost
- **Painel de chamada (TV):** http://localhost:8081
- Login inicial: o que você definiu em `NOVOSGA_ADMIN_USERNAME` / `NOVOSGA_ADMIN_PASSWORD`

Se for acessar de outro computador na rede da unidade de saúde, troque `localhost` pelo IP da máquina onde o Docker está rodando (ex: `http://192.168.0.50`) e ajuste também o `server` em `panel-custom/config.json`.

---

## 6. Comandos úteis de manutenção

### Parar os containers (sem apagar dados)

```bash
docker compose stop
```

### Subir de novo depois de parado

```bash
docker compose start
```

### Derrubar tudo (containers + rede), mantendo o volume do banco

```bash
docker compose down
```

### 🧹 Apagar cache do Symfony (quando alterar templates/config e não refletir no site)

```bash
docker compose exec novosga php bin/console cache:clear
```

Se mesmo assim não atualizar (comum quando se edita arquivo montado por volume), force a recriação do container:

```bash
docker compose down
docker compose up -d --build --force-recreate
```

### 🗑️ Apagar tudo, incluindo o banco de dados (reset total)

```bash
docker compose down -v
```

> `-v` remove os **volumes**, incluindo `mysql_data` — ou seja, apaga todos os dados cadastrados (senhas, atendimentos, usuários). Use só se quiser recomeçar do zero.

### Limpar cache de build do Docker (quando o build trava em versão antiga de código)

```bash
docker compose build --no-cache
docker compose up -d --force-recreate
```

### Ver containers rodando

```bash
docker compose ps
```

### Entrar no terminal do container principal (debug)

```bash
docker compose exec novosga sh
```
---

## Caminhos para trocar imgs

No painel de chamada, todas as imagens estão disponibilizadas no panel-custom/images/ e para modificar em panel-custom/index.html

Já no novosga precisa adicionar a imagem na raiz do projeto, na pasta imagens, caso não tenha crie, e os nomes tem que ser 
- novosga-navbar.png
- novosga-login.png
- favicon.png

---

## como criar e utilizar um novo painel para exibição

No compose.yaml crie a estrutura de um novo painel assim:

```
panel2:
    image: novosga/panel-app
    restart: always
    depends_on:
      - novosga
    ports:
      - "8082:80"
    environment:
      VUE_APP_API_BASE_URL: http://localhost
      VUE_APP_MERCURE_URL: http://localhost:3000/.well-known/mercure
    volumes:
      - ./panel-custom-2:/usr/share/nginx/html
```
Logo após, copie e cole a pasta panel-custom na raiz.

Depois Mude as informações no Config do novo
Após isso, crie o painel no docker:
```
docker compose up -d panel2
```
> Em
>  volumes:
> - ./<strong>panel-custom-2</strong>:/usr/share/nginx/html
> voce troca o nome desse diretório e coloca o nome que tiver na pasta copiada.

o sistema de utinga por exemplo, vai ser um computador/servidor que vai distribuir esse acesso a rede toda, separado por unidades
