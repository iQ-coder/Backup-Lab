#!/bin/bash
# backup.sh - Manual backup script for important-data directory
# Usage: ./backup.sh
# For automated backups, see crontab.txt

SOURCE="/home/vboxuser/important-data/"
DEST="IQ@10.8.0.6:~/backups/"
LOG="/home/vboxuser/backup.log"

echo "=== Backup started: $(date) ===" >> $LOG
rsync -avz $SOURCE $DEST >> $LOG 2>&1
echo "=== Backup completed: $(date) ===" >> $LOG
