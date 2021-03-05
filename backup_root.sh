#!/bin/bash
ENV=/root/.bashrc
NOW=$(date +"%F"_"%H"-"%M")
BKDIR="monthly"
BACKUPDIR="/srv/dev-disk-by-label-DOCUMENTS/anon/odroid/backup/root/$BKDIR"
TARDIR="root"
CDDIR="/"

TAR="/bin/tar"
LOGGER="/bin/logger"
FIND="/usr/bin/find"
CRONTAB="/usr/bin/crontab"
DAY=$(date +%e)

# Store backup path
LAST_MONTH="/srv/dev-disk-by-label-DOCUMENTS/anon/odroid/backup/root/last_month"

# make sure backup directory exists
[ ! -d $BACKUPDIR ] && mkdir -p ${BACKUPDIR}

#If it's Sunday - we delete the initial metadata file and archives
if [ $DAY = "5" ]; then
 NUM="0"
 mkdir -p ${LAST_MONTH}
 rm -rf ${LAST_MONTH}/*
 mv ${BACKUPDIR}/* ${LAST_MONTH}/
 rm -rf ${BACKUPDIR}/*
else
 NUM=$DAY
fi

# Log backup start time in /var/log/messages
$LOGGER "$0: *** ${DOMAIN} ${BKDIR} Backup started @ $(date) ***"

# Backup names
BFILE="$NOW.tar.gz"

# Backup websever dirs
$TAR  -zcvf ${BACKUPDIR}/${BFILE} -C ${CDDIR} "${TARDIR}"

# Log backup end time in /var/log/messages
$LOGGER "$0: *** ${DOMAIN} ${BKDIR} Backup Ended @ $(date) ***"
