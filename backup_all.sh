#!/bin/bash
ENV=/root/.bashrc
########### Common Settings ###########

# Paths for binary files
TAR="/bin/tar"
GZIP="/bin/gzip"
SCP="/usr/bin/scp"
SSH="/usr/bin/ssh"
LOGGER="/bin/logger"
FIND="/usr/bin/find"
CRONTAB="/usr/bin/crontab"
#RMFIND="/bin/find"

EXCLUDE_CONF="/srv/dev-disk-by-label-DOCUMENTS/anon/odroid/backup/all_system/exclude.files.conf"

# Store todays date
NOW=$(date +"%F"_"%H"-"%M")
BKDIR="monthly"
BACKUPDIR="/srv/dev-disk-by-label-DOCUMENTS/anon/odroid/backup/all_system/$BKDIR"
#Get the number of the day of the week
DAY=$(date +%e)

########### END Common Settings ###########

SNAPSHOT_FILE_0="$BACKUPDIR/snapshot_0.snar"
SNAPSHOT_FILE="$BACKUPDIR/snapshot.snar"

CDDIR="/"
TARDIR="./"

# Backup names
BFILE="$NOW.tar.gz"

# Store backup path
LAST_MONTH="/srv/dev-disk-by-label-DOCUMENTS/anon/odroid/backup/all_system/last_month"

# make sure backup directory exists
[ ! -d $BACKUPDIR ] && mkdir -p ${BACKUPDIR}
 
# Log backup start time in /var/log/messages
$LOGGER "$0: *** ${DOMAIN} ${BKDIR} Backup started @ $(date) ***"
 

#Removing the current metadata
rm -rf ${SNAPSHOT_FILE}

#If it's Sunday - we delete the initial metadata file and archives
if [ $DAY = "4" ]; then
 NUM="0"
 mkdir -p ${LAST_MONTH}
 rm -rf ${LAST_MONTH}/*
 mv ${BACKUPDIR}/* ${LAST_MONTH}/
 rm -rf ${SNAPSHOT_FILE_0}
 rm -rf ${BACKUPDIR}/*
else
 NUM=$DAY
fi

#If there is initial metadata, copy it
if [ -f ${SNAPSHOT_FILE_0} ]; then 
	 cp ${SNAPSHOT_FILE_0} ${SNAPSHOT_FILE}
fi

# Backup websever dirs
#$TAR -zcvf ${BACKUP}/${BFILE} "${DIRS}"
$TAR  --exclude-from=${EXCLUDE_CONF} --listed-incremental=${SNAPSHOT_FILE} -zcvf ${BACKUPDIR}/${BFILE} -C ${CDDIR} "${TARDIR}"

$CRONTAB -l > $BACKUPDIR/crontab_$NOW

#If it's Sunday, create an initial copy of the metadata
if [ $DAY = "4" ]; then 
	 cp ${SNAPSHOT_FILE} ${SNAPSHOT_FILE_0}
fi

# Log backup end time in /var/log/messages
$LOGGER "$0: *** ${DOMAIN} ${BKDIR} Backup Ended @ $(date) ***"

