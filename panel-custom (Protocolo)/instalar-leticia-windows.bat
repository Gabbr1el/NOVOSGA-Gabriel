@echo off
setlocal EnableExtensions
chcp 65001 >nul

title Instalacao automatica - RHVoice Leticia

echo ==============================================
echo   RHVoice Leticia - instalacao automatica
echo ==============================================
echo.

rem Eleva para Administrador uma unica vez.
net session >nul 2>&1
if not "%errorlevel%"=="0" (
    echo Solicitando permissao de Administrador...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "URL=https://rhvoice.org/download/RHVoice-Brazilian-Portuguese-voice-Leticia-F123-v4.6.1021.18-setup.exe"
set "INSTALLER=%TEMP%\RHVoice-Leticia-setup.exe"

echo [1/4] Baixando o instalador oficial da voz Leticia...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri $env:URL -OutFile $env:INSTALLER"

if errorlevel 1 goto :download_error
if not exist "%INSTALLER%" goto :download_error

for %%A in ("%INSTALLER%") do if %%~zA LSS 100000 goto :download_error

echo [2/4] Instalando RHVoice Leticia no Windows SAPI5...
echo       A instalacao sera feita automaticamente, sem assistente.

rem Os instaladores SAPI5 do RHVoice sao gerados em formato NSIS.
rem /S e o modo silencioso padrao do NSIS.
start "" /wait "%INSTALLER%" /S
set "INSTALL_CODE=%errorlevel%"

if not "%INSTALL_CODE%"=="0" (
    echo.
    echo [ERRO] O instalador retornou o codigo %INSTALL_CODE%.
    echo Tentando abrir o instalador no modo normal como fallback...
    start "" /wait "%INSTALLER%"
)

echo [3/4] Verificando se a voz foi registrada no SAPI5...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$sapi=New-Object -ComObject SAPI.SpVoice;" ^
  "$tokens=$sapi.GetVoices();" ^
  "$names=@();" ^
  "for($i=0;$i -lt $tokens.Count;$i++){ $names += $tokens.Item($i).GetDescription() };" ^
  "$names | ForEach-Object { Write-Host ('  - ' + $_) };" ^
  "if(-not ($names | Where-Object { $_ -match 'Let|RHVoice' })){ exit 2 }"

if errorlevel 1 goto :sapi_error

echo [4/4] Limpando o instalador temporario...
del /q "%INSTALLER%" >nul 2>&1

echo.
echo ==============================================
echo   INSTALACAO CONCLUIDA COM SUCESSO
echo ==============================================
echo.
echo A voz Leticia esta registrada no SAPI5 do Windows.
echo Nao foi criado nenhum atalho especial para o navegador.
echo.
echo Se o Firefox estiver aberto, feche TODAS as janelas dele.
echo Na proxima vez que abrir o Firefox normalmente, ele podera
echo recarregar a lista de vozes do sistema.
echo.
echo Para conferir no console do navegador:
echo speechSynthesis.getVoices().map(v =^> v.name + " - " + v.lang)
echo.
pause
exit /b 0

:download_error
echo.
echo [ERRO] Nao foi possivel baixar corretamente o instalador oficial.
echo URL: %URL%
echo.
pause
exit /b 1

:sapi_error
echo.
echo [AVISO] O instalador terminou, mas Leticia/RHVoice nao apareceu
echo na enumeracao SAPI5 deste Windows.
echo.
echo O arquivo do instalador foi mantido em:
echo %INSTALLER%
echo.
echo Voce pode executa-lo manualmente para diagnostico.
echo.
pause
exit /b 2
