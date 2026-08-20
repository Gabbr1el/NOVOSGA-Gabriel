$ErrorActionPreference = "Stop"

$Base = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $Base "Config-Backup.ps1")

New-Item -ItemType Directory -Path $PastaLocal -Force | Out-Null
New-Item -ItemType Directory -Path (Split-Path -Parent $ArquivoLog) -Force | Out-Null

function Write-BackupLog {
    param([Parameter(Mandatory=$true)][string]$Mensagem)
    $Data = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Data - $Mensagem" | Out-File -FilePath $ArquivoLog -Append -Encoding utf8
}

function Keep-LatestBackups {
    param(
        [Parameter(Mandatory=$true)][string]$Pasta,
        [Parameter(Mandatory=$true)][int]$Limite
    )

    Get-ChildItem -LiteralPath $Pasta -Filter "backup_*.sql" -File -ErrorAction Stop |
        Sort-Object Name -Descending |
        Select-Object -Skip $Limite |
        Remove-Item -Force -ErrorAction Stop
}

try {
    Write-BackupLog "======================================"
    Write-BackupLog "INICIO DO BACKUP"

    if ($PastaRemota -like "*IP_DO_PC_BACKUP*") {
        throw "Pasta remota ainda nao configurada em Config-Backup.ps1."
    }

    Write-BackupLog "Executando backup no WSL..."

    $SaidaWSL = & wsl.exe -e bash -lc $LinuxScript 2>&1
    $CodigoWSL = $LASTEXITCODE

    foreach ($Linha in $SaidaWSL) {
        Write-BackupLog ([string]$Linha)
    }

    if ($CodigoWSL -ne 0) {
        throw "O script de backup no WSL falhou. Codigo: $CodigoWSL"
    }

    Keep-LatestBackups -Pasta $PastaLocal -Limite $MaxBackups

    if (-not (Test-Path -LiteralPath $PastaRemota)) {
        throw "A pasta remota nao esta acessivel: $PastaRemota"
    }

    Write-BackupLog "Pasta remota acessivel. Sincronizando backups locais..."

    $BackupsLocais = Get-ChildItem -LiteralPath $PastaLocal -Filter "backup_*.sql" -File |
        Sort-Object Name

    foreach ($Backup in $BackupsLocais) {
        $DestinoFinal = Join-Path $PastaRemota $Backup.Name
        $DestinoTemp = "$DestinoFinal.part"

        $PrecisaCopiar = $true

        if (Test-Path -LiteralPath $DestinoFinal) {
            $Remoto = Get-Item -LiteralPath $DestinoFinal
            if ($Remoto.Length -eq $Backup.Length) {
                $PrecisaCopiar = $false
            }
        }

        if ($PrecisaCopiar) {
            Write-BackupLog "Copiando $($Backup.Name)..."

            Remove-Item -LiteralPath $DestinoTemp -Force -ErrorAction SilentlyContinue
            Copy-Item -LiteralPath $Backup.FullName -Destination $DestinoTemp -Force

            $Copiado = Get-Item -LiteralPath $DestinoTemp
            if ($Copiado.Length -ne $Backup.Length) {
                Remove-Item -LiteralPath $DestinoTemp -Force -ErrorAction SilentlyContinue
                throw "Falha na verificacao de tamanho do arquivo $($Backup.Name)."
            }

            Remove-Item -LiteralPath $DestinoFinal -Force -ErrorAction SilentlyContinue
            Move-Item -LiteralPath $DestinoTemp -Destination $DestinoFinal -Force

            Write-BackupLog "Arquivo enviado: $($Backup.Name)"
        }
    }

    Keep-LatestBackups -Pasta $PastaRemota -Limite $MaxBackups

    $QuantidadeLocal = (Get-ChildItem -LiteralPath $PastaLocal -Filter "backup_*.sql" -File).Count
    $QuantidadeRemota = (Get-ChildItem -LiteralPath $PastaRemota -Filter "backup_*.sql" -File).Count

    Write-BackupLog "Backups locais: $QuantidadeLocal"
    Write-BackupLog "Backups remotos: $QuantidadeRemota"
    Write-BackupLog "BACKUP CONCLUIDO COM SUCESSO"

    exit 0
}
catch {
    Write-BackupLog "ERRO: $($_.Exception.Message)"
    Write-Error $_.Exception.Message
    exit 1
}
