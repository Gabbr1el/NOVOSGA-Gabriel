# Implantacao segura - Secretaria de Saude de Utinga

Este procedimento considera o ambiente descrito no `compose.yaml`: aplicacao `novosga`, banco MySQL `mysqldb`, banco `novosga2` e branch Git `Utinga`.

## Antes de ir a producao

No computador de desenvolvimento, dentro deste repositorio, publique o commit testado:

```bash
git push origin Utinga
```

O deploy usa Git porque ele valida o estado anterior, transfere todos os arquivos juntos e permite voltar exatamente ao commit anterior. Nao copie arquivos individualmente.

## Deploy

1. No Windows da unidade, feche as telas de atendimento ou avise que havera uma pausa curta. Abra o PowerShell na pasta do repositorio e entre no WSL mantendo a pasta atual:

```powershell
wsl --cd . bash
```

O prompt deve mudar para o Bash do Ubuntu. Todos os comandos seguintes, ate a secao de verificacao no navegador, sao executados nesse Bash.

2. Confirme que esta no repositorio correto e na branch correta:

```bash
git rev-parse --show-toplevel
git branch --show-current
docker compose ps
```

O segundo comando deve mostrar `Utinga`. Em `docker compose ps`, `novosga` e `mysqldb` devem estar `Up`; o banco deve aparecer como `healthy`.

3. Confirme que nao existem alteracoes locais desconhecidas:

```bash
git status --short
```

O resultado correto e nenhuma linha. Se aparecer qualquer arquivo, pare o deploy e guarde uma captura da tela. Nao use `git reset`, `git checkout` nem `git stash` sem antes analisar esses arquivos.

4. Crie a pasta de backup e registre o commit anterior:

```bash
STAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$PWD/backup-deploy-$STAMP"
mkdir -p "$BACKUP_DIR"
git rev-parse HEAD | tee "$BACKUP_DIR/commit-anterior.txt"
docker image tag novosga/novosga:2.2-standalone "novosga/novosga:rollback-$STAMP"
docker compose config > "$BACKUP_DIR/compose-resolvido.yaml"
chmod 600 "$BACKUP_DIR/compose-resolvido.yaml"
```

Guarde o valor de `STAMP` exibindo-o:

```bash
printf '%s\n' "$STAMP"
```

5. Faca o dump consistente do banco antes de alterar codigo ou schema:

```bash
docker compose exec -T mysqldb sh -c 'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --single-transaction --routines --triggers --add-drop-database --databases novosga2' > "$BACKUP_DIR/novosga2-$STAMP.sql"
test -s "$BACKUP_DIR/novosga2-$STAMP.sql" && printf 'BACKUP DO BANCO OK\n'
du -h "$BACKUP_DIR/novosga2-$STAMP.sql"
```

O resultado deve conter `BACKUP DO BANCO OK` e um tamanho maior que zero. Se nao aparecer, pare o deploy.

6. Verifique o dump sem exibir dados de pacientes:

```bash
grep -q 'CREATE DATABASE' "$BACKUP_DIR/novosga2-$STAMP.sql" && printf 'ESTRUTURA PRESENTE NO BACKUP\n'
grep -q 'CREATE TABLE.*clientes' "$BACKUP_DIR/novosga2-$STAMP.sql" && printf 'TABELA CLIENTES PRESENTE NO BACKUP\n'
```

As duas mensagens devem aparecer.

7. Busque o codigo remoto sem modificar o codigo em uso:

```bash
git fetch origin Utinga
git log --oneline HEAD..origin/Utinga
```

Deve aparecer o commit desta customizacao. Se nao aparecer nenhum commit, confirme se `git push origin Utinga` foi executado no computador de desenvolvimento.

8. Atualize somente por avancar a branch, sem criar merge inesperado:

```bash
git merge --ff-only origin/Utinga
git status --short --branch
```

O merge deve terminar sem conflito. O status nao deve listar arquivos modificados.

9. Construa a nova imagem. A aplicacao antiga continua atendendo durante esta etapa:

```bash
docker compose build novosga
```

O final correto contem `Image novosga/novosga:2.2-standalone Built`. Em uma maquina de 4 GB, aguarde alguns minutos e nao feche a janela.

10. Execute a migration aditiva usando a imagem nova:

```bash
docker compose run --rm novosga php bin/console doctrine:migrations:migrate --no-interaction
```

O resultado correto contem `Successfully migrated to version: DoctrineMigrations\Version20260824170000`. A migration apenas adiciona duas colunas booleanas, ambas inicialmente liberadas.

11. Confirme as colunas e os valores retrocompativeis:

```bash
docker compose exec -T mysqldb mysql -unovosga -p150769 novosga2 -e "SHOW COLUMNS FROM locais LIKE 'permite_trocar_%'; SELECT COUNT(*) AS bloqueios_inesperados FROM locais WHERE permite_trocar_local <> 1 OR permite_trocar_numero <> 1;"
```

Devem aparecer `permite_trocar_local`, `permite_trocar_numero` e `bloqueios_inesperados` igual a `0`.

12. Recrie somente a aplicacao, sem reiniciar MySQL, paineis ou Mercure:

```bash
docker compose up -d --no-deps novosga
docker compose ps novosga mysqldb
```

O `novosga` pode ficar `health: starting` por alguns segundos. Aguarde e confira novamente:

```bash
sleep 15
docker compose ps novosga mysqldb
curl -I http://127.0.0.1:8080/login
```

O esperado e `novosga` e `mysqldb` em `Up`, banco `healthy` e resposta HTTP `200`. A indisponibilidade esperada ocorre apenas na recriacao do `novosga`, normalmente entre 5 e 30 segundos.

13. Verifique se nao houve erro de inicializacao:

```bash
docker compose logs --since 5m novosga
```

As linhas normais incluem `ready to handle connections`. Pare e aplique o rollback se houver `Fatal error`, `SQLSTATE`, `Migration` com erro ou reinicios repetidos.

## Configuracao das travas

1. Entre no NovoSGA como administrador.
2. Acesse `Administracao > Locais`.
3. Edite o local `Sala`.
4. Desmarque `Permitir que o atendente troque o local`.
5. Mantenha marcado `Permitir que o atendente troque o numero da sala`.
6. Salve.
7. Edite o local correspondente ao TFD. No banco local analisado ele se chama `Sala do TFD`; use o nome que estiver cadastrado em producao.
8. Desmarque as duas opcoes de troca e salve.

Nao ha hardcode pelos nomes: as duas permissoes podem ser alteradas independentemente em qualquer local.

## Checklist na tela

1. Monitor: abra `Monitor`, confirme os campos `Nome do paciente` e `CPF`, pesquise uma senha emitida e abra o resultado. Confirme que nome e CPF correspondem antes de testar o botao de cancelamento. Nao cancele uma senha real apenas para teste.
2. Emissao: gere uma senha de teste autorizada e confirme que o popup mostra `Senha gerada:`.
3. CPF em Pacientes: tente salvar um paciente com 10 digitos. Deve aparecer o popup e o cadastro nao deve ser salvo. Depois use 11 digitos em um cadastro de teste e confirme o salvamento; remova o registro de teste se necessario.
4. CPF na Emissao: informe documento com menos de 11 digitos e tente emitir. Deve aparecer `CPF invalido` e nenhuma senha deve ser criada.
5. Local `Sala`: na tela de atendimento, confirme que o seletor de local esta bloqueado e o numero da sala continua habilitado.
6. Local do TFD: confirme que tanto o seletor de local quanto o numero da sala estao bloqueados.
7. Painel: faca uma chamada de teste autorizada e confirme que os paineis nas portas `8081` e `8082` continuam atualizando.

## Rollback somente da aplicacao

Use este rollback se a interface ou a aplicacao nova apresentar problema, mas o banco continuar integro. As duas colunas novas sao aditivas e podem permanecer sem afetar a versao anterior.

1. No Bash do WSL, volte para a pasta do repositorio. Se a variavel foi perdida por fechar a janela, descubra o nome da pasta de backup:

```bash
ls -d backup-deploy-*
```

2. Selecione automaticamente a pasta de backup mais recente e confira o caminho exibido:

```bash
BACKUP_DIR=$(ls -dt "$PWD"/backup-deploy-* | head -n 1)
STAMP=${BACKUP_DIR##*-deploy-}
OLD_COMMIT=$(cat "$BACKUP_DIR/commit-anterior.txt")
printf '%s\n' "$BACKUP_DIR"
```

3. Pare somente a aplicacao, volte o codigo e restaure a imagem guardada:

```bash
docker compose stop novosga
git reset --hard "$OLD_COMMIT"
docker image tag "novosga/novosga:rollback-$STAMP" novosga/novosga:2.2-standalone
docker compose up -d --no-deps novosga
sleep 15
docker compose ps novosga mysqldb
curl -I http://127.0.0.1:8080/login
```

O login deve responder HTTP `200`. Esse procedimento pressupoe que o passo 3 do deploy confirmou uma arvore Git limpa.

## Rollback completo com restauracao do banco

Use somente se houve corrupcao ou alteracao indevida de dados. Isso elimina tudo que foi registrado depois do backup, portanto execute com a unidade sem atendimento.

1. Confirme visualmente que escolheu o backup correto:

```bash
printf '%s\n' "$BACKUP_DIR"
ls -lh "$BACKUP_DIR"/novosga2-*.sql
```

2. Pare todos os servicos que podem acessar o banco:

```bash
docker compose stop novosga restore-panel
```

3. Restaure o dump. O proprio arquivo remove e recria apenas o banco `novosga2`:

```bash
docker compose exec -T mysqldb sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD"' < "$BACKUP_DIR/novosga2-$STAMP.sql"
```

Nenhuma mensagem e o resultado normal. Se aparecer `ERROR`, nao inicie a aplicacao e guarde uma captura.

4. Volte o codigo e a imagem anterior e inicie os servicos:

```bash
OLD_COMMIT=$(cat "$BACKUP_DIR/commit-anterior.txt")
git reset --hard "$OLD_COMMIT"
docker image tag "novosga/novosga:rollback-$STAMP" novosga/novosga:2.2-standalone
docker compose up -d mysqldb
docker compose up -d --no-deps novosga
docker compose up -d restore-panel
sleep 15
docker compose ps
curl -I http://127.0.0.1:8080/login
```

5. Entre no sistema e confira pacientes, fila atual e historico antes de liberar o uso.
