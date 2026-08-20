Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$Base = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $Base "Config-Backup.ps1")
$ScriptPrincipal = Join-Path $Base "Backup-NovoSGA.ps1"

$form = New-Object System.Windows.Forms.Form
$form.Text = "Backup NovoSGA"
$form.Size = New-Object System.Drawing.Size(620,430)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

$titulo = New-Object System.Windows.Forms.Label
$titulo.Text = "Backup do banco de dados NovoSGA"
$titulo.Font = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$titulo.AutoSize = $true
$titulo.Location = New-Object System.Drawing.Point(28, 25)
$form.Controls.Add($titulo)

$status = New-Object System.Windows.Forms.Label
$status.Text = "Pronto."
$status.AutoSize = $true
$status.Location = New-Object System.Drawing.Point(30, 70)
$form.Controls.Add($status)

$botaoBackup = New-Object System.Windows.Forms.Button
$botaoBackup.Text = "Fazer backup agora"
$botaoBackup.Size = New-Object System.Drawing.Size(170, 42)
$botaoBackup.Location = New-Object System.Drawing.Point(30, 105)
$form.Controls.Add($botaoBackup)

$botaoLocal = New-Object System.Windows.Forms.Button
$botaoLocal.Text = "Abrir backups locais"
$botaoLocal.Size = New-Object System.Drawing.Size(170, 42)
$botaoLocal.Location = New-Object System.Drawing.Point(215, 105)
$form.Controls.Add($botaoLocal)

$botaoLog = New-Object System.Windows.Forms.Button
$botaoLog.Text = "Abrir log"
$botaoLog.Size = New-Object System.Drawing.Size(170, 42)
$botaoLog.Location = New-Object System.Drawing.Point(400, 105)
$form.Controls.Add($botaoLog)

$labelLista = New-Object System.Windows.Forms.Label
$labelLista.Text = "Backups locais mais recentes:"
$labelLista.AutoSize = $true
$labelLista.Location = New-Object System.Drawing.Point(30, 170)
$form.Controls.Add($labelLista)

$lista = New-Object System.Windows.Forms.ListBox
$lista.Location = New-Object System.Drawing.Point(30, 195)
$lista.Size = New-Object System.Drawing.Size(540, 145)
$form.Controls.Add($lista)

function Atualizar-Lista {
    $lista.Items.Clear()
    if (Test-Path -LiteralPath $PastaLocal) {
        Get-ChildItem -LiteralPath $PastaLocal -Filter "backup_*.sql" -File |
            Sort-Object Name -Descending |
            Select-Object -First $MaxBackups |
            ForEach-Object {
                $TamanhoMB = [math]::Round($_.Length / 1MB, 2)
                [void]$lista.Items.Add("$($_.Name)   -   $TamanhoMB MB")
            }
    }
}

$botaoBackup.Add_Click({
    $botaoBackup.Enabled = $false
    $status.Text = "Executando backup e sincronizacao..."
    $form.Refresh()

    $Argumentos = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$ScriptPrincipal`""
    )

    $Processo = Start-Process -FilePath "powershell.exe" -ArgumentList $Argumentos -Wait -PassThru -WindowStyle Hidden

    if ($Processo.ExitCode -eq 0) {
        $status.Text = "Backup concluido com sucesso."
        [System.Windows.Forms.MessageBox]::Show(
            "O backup foi criado e sincronizado com o computador de backup.",
            "NovoSGA",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
    }
    else {
        $status.Text = "Falha no backup. Consulte o log."
        [System.Windows.Forms.MessageBox]::Show(
            "O backup falhou. Consulte: $ArquivoLog",
            "NovoSGA",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }

    Atualizar-Lista
    $botaoBackup.Enabled = $true
})

$botaoLocal.Add_Click({
    New-Item -ItemType Directory -Path $PastaLocal -Force | Out-Null
    Start-Process explorer.exe $PastaLocal
})

$botaoLog.Add_Click({
    if (Test-Path -LiteralPath $ArquivoLog) {
        Start-Process notepad.exe $ArquivoLog
    }
    else {
        [System.Windows.Forms.MessageBox]::Show(
            "O arquivo de log ainda nao existe.",
            "NovoSGA",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
    }
})

Atualizar-Lista
[void]$form.ShowDialog()
