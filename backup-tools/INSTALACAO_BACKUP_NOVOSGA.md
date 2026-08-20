# Instalação do Backup Automático do NovoSGA

Este guia considera a seguinte estrutura no **servidor do NovoSGA**:

```text
C:\NovoSGA\
├── NovoSGA-Gabriel\
│   ├── Sistema principal do NovoSGA
│   └── backup-tools\
│       ├── Config-Backup.ps1
│       ├── Backup-NovoSGA.ps1
│       ├── Backup-NovoSGA-GUI.ps1
│       └── wsl\
│           ├── backup.sh
│           └── backup.env
│
└── NovoSGA_Backups\
    └── backups .sql
```

No computador que **recebe** os backups:

```text
C:\NovoSGA_Backups\
└── backups .sql
```

> O sistema mantém **no máximo 7 backups** no servidor e **7 backups** no computador receptor. Ao entrar o 8º, o mais antigo é apagado.

---

## 1. No PC que vai RECEBER os backups

### Powershell como Administrador

Coloque o arquivo `Preparar-PC-Backup.ps1` no computador receptor.

Abra o **PowerShell como Administrador**.

Para liberar a execução apenas nessa janela do PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```

Execute o script:

```powershell
& "CAMINHO\Preparar-PC-Backup.ps1"
```

Por exemplo, se estiver em `C:\NovoSGA`:

```powershell
& "C:\NovoSGA\Preparar-PC-Backup.ps1"
```

O script vai:

- criar o usuário `backupnovosga`;
- pedir para você criar uma senha para esse usuário;
- criar `C:\NovoSGA_Backups`;
- compartilhar a pasta na rede como `NovoSGA_Backups`;
- configurar a permissão do usuário de backup;
- liberar a porta SMB 445 para rede privada;
- mostrar o nome do computador e os IPv4 encontrados.

> **Guarde a senha criada para o usuário `backupnovosga`. Você vai precisar dela no servidor.**

---

## 2. Anote o IPv4 e o nome do PC receptor

Ainda no PowerShell do PC receptor:

```powershell
hostname
```

Depois:

```powershell
ipconfig
```

Ou:

```powershell
Get-NetIPAddress -AddressFamily IPv4
```

Anote algo como:

```text
Nome do PC: PC-BACKUP
IPv4: 192.168.1.50
```

Confira também se a rede do Windows está como **Privada**:

```powershell
Get-NetConnectionProfile
```

Se aparecer `NetworkCategory : Public`, altere a conexão usada pelo computador para **Privada** nas Configurações de Rede do Windows antes de continuar.

> É recomendado reservar esse IPv4 no roteador para que o endereço do PC receptor não mude posteriormente.

---

## 3. No SERVIDOR, coloque os scripts dentro do projeto

Essa etapa é feita no **Windows do computador onde o NovoSGA está rodando**.

A pasta principal é:

```text
C:\NovoSGA\NovoSGA-Gabriel
```

Crie a pasta dos scripts:

```powershell
New-Item -ItemType Directory -Path "C:\NovoSGA\NovoSGA-Gabriel\backup-tools\wsl" -Force
```

A estrutura deve ficar assim:

```text
C:\NovoSGA\NovoSGA-Gabriel\backup-tools\
├── Config-Backup.ps1
├── Backup-NovoSGA.ps1
├── Backup-NovoSGA-GUI.ps1
└── wsl\
    ├── backup.sh
    └── backup.env
```

Crie também a pasta que armazenará os backups locais:

```powershell
New-Item -ItemType Directory -Path "C:\NovoSGA\NovoSGA_Backups" -Force
```

> O arquivo `Preparar-PC-Backup.ps1` **não precisa ficar no servidor**. Ele é usado no PC que recebe os backups.

---

## 4. Configure o IP do PC receptor

No servidor, abra:

```text
C:\NovoSGA\NovoSGA-Gabriel\backup-tools\Config-Backup.ps1
```

A configuração local deve ficar assim:

```powershell
$PastaLocal = "C:\NovoSGA\NovoSGA_Backups"
```

Na pasta remota, coloque o IPv4 anotado anteriormente.

Exemplo:

```powershell
$PastaRemota = "\\192.168.1.50\NovoSGA_Backups"
```

A quantidade máxima deve permanecer:

```powershell
$MaxBackups = 7
```

E o log pode ficar dentro dos scripts:

```powershell
$ArquivoLog = "C:\NovoSGA\NovoSGA-Gabriel\backup-tools\backup.log"
```

Salve o arquivo.

---

## 5. Salve a credencial do PC receptor no SERVIDOR

Ainda no Windows do servidor, pressione `Win + R` e execute:

```text
control /name Microsoft.CredentialManager
```

Entre em:

**Credenciais do Windows → Adicionar uma credencial do Windows**

Preencha:

```text
Endereço: 192.168.1.50
Usuário: PC-BACKUP\backupnovosga
Senha: a senha criada no passo 1
```

Troque `192.168.1.50` e `PC-BACKUP` pelos valores reais.

Depois teste no PowerShell do servidor:

```powershell
Test-Path "\\192.168.1.50\NovoSGA_Backups"
```

O esperado é:

```text
True
```

Também pode abrir diretamente pelo Explorador de Arquivos:

```text
\\192.168.1.50\NovoSGA_Backups
```

> Salve a credencial usando **a mesma conta do Windows que será usada para executar o backup e a tarefa agendada**.

---

## 6. Copie os scripts Linux para dentro do WSL2

Abra o **Ubuntu/WSL2** no servidor.

Crie a pasta:

```bash
mkdir -p ~/novosga-backup
```

Copie o `backup.sh`:

```bash
cp /mnt/c/NovoSGA/NovoSGA-Gabriel/backup-tools/wsl/backup.sh ~/novosga-backup/backup.sh
```

Copie o `backup.env`:

```bash
cp /mnt/c/NovoSGA/NovoSGA-Gabriel/backup-tools/wsl/backup.env ~/novosga-backup/backup.env
```

Confira:

```bash
ls -la ~/novosga-backup
```

Deve aparecer:

```text
backup.sh
backup.env
```

---

## 7. Configure as permissões no WSL2

Ainda no Ubuntu/WSL2:

```bash
chmod 700 ~/novosga-backup/backup.sh
```

```bash
chmod 600 ~/novosga-backup/backup.env
```

Confira:

```bash
ls -l ~/novosga-backup
```

O `backup.env` deve ficar acessível apenas pelo seu usuário Linux.

### Confira o `backup.env`

Abra:

```bash
nano ~/novosga-backup/backup.env
```

A pasta local deve ser:

```bash
PASTA_LOCAL="/mnt/c/NovoSGA/NovoSGA_Backups"
```

A quantidade máxima:

```bash
MAX_BACKUPS=7
```

O serviço MySQL deve ser:

```bash
SERVICO_MYSQL="mysqldb"
```

> **Não coloque `novosga-gabriel-mysqldb-1` no script.** O backup procura o container pelo nome do serviço Docker Compose `mysqldb`, então o nome físico do container pode mudar entre computadores.

O banco usado atualmente é:

```bash
BANCO_MYSQL="novosga2"
USER_MYSQL="novosga"
```

Confira também se a senha configurada em `SENHA_MYSQL` corresponde à senha do MySQL dessa instalação.

Para salvar no `nano`:

```text
Ctrl + O
Enter
Ctrl + X
```

Depois reaplique a proteção:

```bash
chmod 600 ~/novosga-backup/backup.env
```

---

## 8. Teste o backup diretamente pelo WSL2

Primeiro confira se o Docker está funcionando:

```bash
docker ps --format "table {{.Names}}\t{{.Image}}"
```

Confira especificamente o serviço MySQL:

```bash
docker ps --filter "label=com.docker.compose.service=mysqldb" --format "table {{.Names}}\t{{.Image}}"
```

Deve aparecer **um** container MySQL.

O nome pode ser, por exemplo:

```text
novosga-gabriel-mysqldb-1
```

ou qualquer outro nome gerado pelo Docker Compose. Isso não exige alteração do script.

Agora execute:

```bash
~/novosga-backup/backup.sh
```

O esperado no final é:

```text
BACKUP CONCLUIDO COM SUCESSO
```

Confira a pasta pelo WSL:

```bash
ls -lh /mnt/c/NovoSGA/NovoSGA_Backups
```

Ou abra no Windows:

```text
C:\NovoSGA\NovoSGA_Backups
```

Deve existir um arquivo parecido com:

```text
backup_20260820_230000.sql
```

> Só prossiga se esse teste funcionar.

---

## 9. Teste o processo completo pelo PowerShell

Agora volte para o **PowerShell do Windows do servidor**.

Execute:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\NovoSGA\NovoSGA-Gabriel\backup-tools\Backup-NovoSGA.ps1"
```

Esse teste deve:

1. chamar o `backup.sh` dentro do WSL2;
2. gerar um novo `.sql` em `C:\NovoSGA\NovoSGA_Backups`;
3. acessar o compartilhamento do PC receptor;
4. copiar os backups que ainda não estiverem nele;
5. manter somente os 7 mais recentes no servidor;
6. manter somente os 7 mais recentes no PC receptor;
7. registrar o resultado em `backup.log`.

Confira o log:

```powershell
Get-Content "C:\NovoSGA\NovoSGA-Gabriel\backup-tools\backup.log" -Tail 50
```

Confira os arquivos locais:

```powershell
Get-ChildItem "C:\NovoSGA\NovoSGA_Backups"
```

Confira os arquivos no PC receptor:

```powershell
Get-ChildItem "\\192.168.1.50\NovoSGA_Backups"
```

> Troque o IPv4 pelo IP real do computador receptor.

---

## 10. Teste a interface gráfica do backup

No PowerShell do servidor:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\NovoSGA\NovoSGA-Gabriel\backup-tools\Backup-NovoSGA-GUI.ps1"
```

Na interface, clique em:

```text
Fazer backup agora
```

Depois confirme se o novo arquivo apareceu nos dois lugares:

```text
Servidor:
C:\NovoSGA\NovoSGA_Backups

PC receptor:
\\IP_DO_PC\NovoSGA_Backups
```

Teste também os botões de abrir a pasta local e abrir o log.

> Configure o backup automático somente depois que o backup manual pela interface estiver funcionando.

---

## 11. Configure o Agendador de Tarefas do Windows

No servidor, pressione `Win + R` e execute:

```text
taskschd.msc
```

Clique em:

```text
Criar Tarefa
```

### Geral

Nome:

```text
Backup NovoSGA
```

Marque:

```text
Executar independentemente de o usuário estar conectado
Executar com privilégios mais altos
```

> Use a mesma conta do Windows na qual você salvou a credencial do PC receptor.

### Disparadores

Clique em **Novo**.

Exemplo:

```text
Diariamente
23:00
```

### Ações

Programa/script:

```text
powershell.exe
```

Adicionar argumentos:

```text
-NoProfile -ExecutionPolicy Bypass -File "C:\NovoSGA\NovoSGA-Gabriel\backup-tools\Backup-NovoSGA.ps1"
```

### Configurações

Marque:

```text
Executar a tarefa o mais cedo possível depois que um início agendado for perdido
```

Salve a tarefa.

O Windows pode pedir a senha da conta do Windows que executará a tarefa.

### Teste a tarefa

No Agendador de Tarefas:

```text
Biblioteca do Agendador de Tarefas
→ Backup NovoSGA
→ botão direito
→ Executar
```

Depois confira:

```powershell
Get-Content "C:\NovoSGA\NovoSGA-Gabriel\backup-tools\backup.log" -Tail 50
```

---

# Fluxo final

```text
SERVIDOR WINDOWS
C:\NovoSGA\NovoSGA-Gabriel
        │
        │ Docker / WSL2
        ▼
MySQL - serviço mysqldb
        │
        │ mysqldump --hex-blob --no-tablespaces
        ▼
C:\NovoSGA\NovoSGA_Backups
        │
        │ SMB pela rede
        ▼
PC RECEPTOR
C:\NovoSGA_Backups
```

Nos dois computadores ficam no máximo:

```text
7 backups .sql
```

Quando o 8º backup é criado, o mais antigo é removido.

---

# Guia de alterações

## Alterar o IP do PC receptor

Arquivo:

```text
C:\NovoSGA\NovoSGA-Gabriel\backup-tools\Config-Backup.ps1
```

Altere:

```powershell
$PastaRemota = "\\NOVO_IP\NovoSGA_Backups"
```

Depois atualize também a credencial salva no **Gerenciador de Credenciais do Windows**.

---

## Alterar a quantidade máxima de backups

No Windows, altere em:

```text
C:\NovoSGA\NovoSGA-Gabriel\backup-tools\Config-Backup.ps1
```

Exemplo para 10:

```powershell
$MaxBackups = 10
```

No WSL2, altere também:

```bash
nano ~/novosga-backup/backup.env
```

Para:

```bash
MAX_BACKUPS=10
```

> Mantenha os dois valores iguais.

---

## Alterar banco, usuário ou senha do MySQL

No WSL2:

```bash
nano ~/novosga-backup/backup.env
```

Altere:

```bash
USER_MYSQL="novosga"
SENHA_MYSQL="SENHA_DO_MYSQL"
BANCO_MYSQL="novosga2"
```

Depois:

```bash
chmod 600 ~/novosga-backup/backup.env
```

---

## Se o nome físico do container Docker mudar

**Não altere nada.**

Exemplos de nomes que podem aparecer:

```text
novosga-gabriel-mysqldb-1
novosga-mysqldb-1
secretaria-mysqldb-1
```

O script usa:

```bash
SERVICO_MYSQL="mysqldb"
```

Ele encontra o container pela label do serviço Docker Compose.

Só altere `SERVICO_MYSQL` se o próprio nome do serviço no `compose.yml` mudar de `mysqldb` para outro nome.

---

## Se houver mais de um projeto com `mysqldb` rodando no mesmo WSL

No WSL2:

```bash
docker ps --filter "label=com.docker.compose.service=mysqldb" --format "table {{.Names}}\t{{.Label \"com.docker.compose.project\"}}"
```

Depois edite:

```bash
nano ~/novosga-backup/backup.env
```

E defina:

```bash
COMPOSE_PROJECT="NOME_DO_PROJETO"
```

Normalmente isso deve permanecer vazio:

```bash
COMPOSE_PROJECT=""
```

---

## Alterar o horário do backup automático

Abra:

```text
taskschd.msc
```

Entre em:

```text
Backup NovoSGA → Propriedades → Disparadores
```

Altere o horário e salve.

---

# Teste rápido após qualquer alteração

### WSL2

```bash
~/novosga-backup/backup.sh
```

### PowerShell

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\NovoSGA\NovoSGA-Gabriel\backup-tools\Backup-NovoSGA.ps1"
```

### Verificar local

```powershell
Get-ChildItem "C:\NovoSGA\NovoSGA_Backups"
```

### Verificar receptor

```powershell
Get-ChildItem "\\IP_DO_PC\NovoSGA_Backups"
```

### Verificar log

```powershell
Get-Content "C:\NovoSGA\NovoSGA-Gabriel\backup-tools\backup.log" -Tail 50
```

---

# Restauração

Os backups são gerados no formato:

```text
backup_YYYYMMDD_HHMMSS.sql
```

Esse é o formato `.sql` aceito pela interface de restauração do seu sistema.

Para restaurar, escolha um dos arquivos `.sql` da pasta de backups e envie pela interface de restauração.

> Antes de colocar a automação em produção, faça pelo menos um teste completo de restauração com um backup de teste.
