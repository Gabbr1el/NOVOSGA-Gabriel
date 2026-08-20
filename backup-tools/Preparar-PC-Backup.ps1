# Execute este arquivo no PC QUE VAI RECEBER os backups.
# Abra o PowerShell como Administrador antes de executar.

$ErrorActionPreference = "Stop"

$UsuarioBackup = "backupnovosga"
$PastaBackup = "C:\NovoSGA_Backups"
$NomeCompartilhamento = "NovoSGA_Backups"

$Identidade = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = New-Object Security.Principal.WindowsPrincipal($Identidade)
if (-not $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Execute este script no PowerShell como Administrador."
}

Write-Host "Preparando o PC receptor do backup NovoSGA..." -ForegroundColor Cyan
Write-Host

if (-not (Get-LocalUser -Name $UsuarioBackup -ErrorAction SilentlyContinue)) {
    $Senha = Read-Host "Crie a senha do usuario '$UsuarioBackup'" -AsSecureString
    $ParametrosUsuario = @{
        Name = $UsuarioBackup
        Password = $Senha
        FullName = "Backup NovoSGA"
        Description = "Usuario exclusivo para receber backups do NovoSGA"
        PasswordNeverExpires = $true
    }
    New-LocalUser @ParametrosUsuario | Out-Null
    Write-Host "Usuario criado: $UsuarioBackup"
}
else {
    Write-Host "Usuario ja existe: $UsuarioBackup"
}

New-Item -ItemType Directory -Path $PastaBackup -Force | Out-Null

$Conta = "$env:COMPUTERNAME\$UsuarioBackup"
icacls $PastaBackup /grant "${Conta}:(OI)(CI)M" | Out-Null

$Share = Get-SmbShare -Name $NomeCompartilhamento -ErrorAction SilentlyContinue
if ($Share) {
    if ($Share.Path -ne $PastaBackup) {
        throw "Ja existe um compartilhamento '$NomeCompartilhamento' apontando para outra pasta: $($Share.Path)"
    }
}
else {
    $ParametrosShare = @{
        Name = $NomeCompartilhamento
        Path = $PastaBackup
        ChangeAccess = $Conta
    }
    New-SmbShare @ParametrosShare | Out-Null
}

$Regra = Get-NetFirewallRule -DisplayName "NovoSGA Backup SMB" -ErrorAction SilentlyContinue
if (-not $Regra) {
    $ParametrosFirewall = @{
        DisplayName = "NovoSGA Backup SMB"
        Direction = "Inbound"
        Action = "Allow"
        Protocol = "TCP"
        LocalPort = 445
        Profile = "Private"
    }
    New-NetFirewallRule @ParametrosFirewall | Out-Null
}

Write-Host
Write-Host "Configuracao concluida." -ForegroundColor Green
Write-Host "Nome do PC: $env:COMPUTERNAME"
Write-Host "Pasta: $PastaBackup"
Write-Host "Compartilhamento: $NomeCompartilhamento"
Write-Host "Usuario: $Conta"
Write-Host
Write-Host "IPv4 disponiveis:" -ForegroundColor Yellow
Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" } |
    Select-Object InterfaceAlias, IPAddress |
    Format-Table -AutoSize

Write-Host "IMPORTANTE: a regra de firewall criada vale apenas para perfil de rede Privado."
Write-Host "Confira o perfil com: Get-NetConnectionProfile"
