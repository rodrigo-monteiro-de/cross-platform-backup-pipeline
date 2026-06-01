#!/bin/bash

DATA=$(TZ="America/Sao_Paulo" date +"%Y%m%d_%H%M")
BACKUP_DIR="/home/user/mysql-backup-pipeline/"
CONTAINER="mysql-container"
DB_NAME="sample_database"
INICIO=$(date +%s)

# Criar pasta de backup se não existir
mkdir -p "$BACKUP_DIR"

LOG_FILE="$BACKUP_DIR/backup.log"

exec >> "$LOG_FILE" 2>&1

echo "================================================================================="
echo "Iniciado backup em $(TZ="America/Sao_Paulo" date +"%d/%m/%Y_%H:%M:%S.%3N")"

# Copia o arquivo oculto para dentro do container
docker cp /home/user/mysql-backup-pipeline/.my.cnf "$CONTAINER":/tmp/.my.cnf

docker exec "$CONTAINER" sh -c "mysqldump --defaults-extra-file=/tmp/.my.cnf $DB_NAME" \
> "$BACKUP_DIR/backup_$DATA.sql"

if [ $? -eq 0 ]; then
	echo "Backup gerado com sucesso."
else
	echo ">>>> ERRO: falha ao gerar backup <<<<<<< "
fi
FIM=$(date +%s)
TEMPO=$((FIM - INICIO))
echo "Tempo total:${TEMPO} segundos"

echo "Finalizado backup em  $(TZ="America/Sao_Paulo" date +"%d/%m/%Y_%H:%M:%S.%3N")"
echo "================================================================================="
