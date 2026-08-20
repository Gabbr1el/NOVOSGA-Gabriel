# ============================================================
# CONFIGURACAO CENTRAL DO BACKUP NOVOSGA
# ============================================================

# Pasta local do Windows onde o WSL grava os .sql
$PastaLocal = "C:\NovoSGA\NovoSGA_Backups"

# ALTERAR QUANDO SOUBER O IP OU NOME DO PC DE BACKUP.
# Exemplos:
# $PastaRemota = "\\192.168.1.50\NovoSGA_Backups"
# $PastaRemota = "\\PC-BACKUP\NovoSGA_Backups"
$PastaRemota = "\\IP_DO_PC_BACKUP\NovoSGA_Backups"

# Script Linux. Usa a distribuicao WSL padrao e o usuario Linux padrao.
$LinuxScript = "~/novosga-backup/backup.sh"

# Quantidade maxima de backups em cada computador
$MaxBackups = 7

# Arquivo de log do processo completo
$ArquivoLog = "C:\NovoSGA\NovoSGA-Gabriel\backup-tools\backup.log"
