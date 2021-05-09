#!/bin/bash
#ENV=/root/.bashrc
########### Common Settings ###########

# Paths for binary files
TAR="/bin/tar"
GZIP="/bin/gzip"
SCP="/usr/bin/scp"
SSH="/usr/bin/ssh"
LOGGER="/bin/logger"
FIND="/usr/bin/find"
CRONTAB="/usr/bin/crontab"

EXCLUDE_CONF="/home/user/backup_scripts_vps/exclude.files.conf"

# Store todays date
NOW=$(date +"%F"_"%H"-"%M")
BKDIR="weekly"
BACKUPDIR="/mnt/sdb1/backups/all_system/$BKDIR"
#Get the number of the day of the week
DAY=$(date +%e)

########### END Common Settings ###########

SNAPSHOT_FILE_0="$BACKUPDIR/snapshot_0.snar"
SNAPSHOT_FILE="$BACKUPDIR/snapshot.snar"

CDDIR="/"
TARDIR="*"

# Backup names
BFILE="$NOW.tar.gz"

# Store backup path
LAST_WEEK="/mnt/sdb1/backups/all_system/last_week"

# make sure backup directory exists
[ ! -d $BACKUPDIR ] && mkdir -p ${BACKUPDIR}
 
# Log backup start time in /var/log/messages
$LOGGER "$0: ***  ${BKDIR} Backup started @ $(date) ***"
 

#Removing the current metadata
rm -rf ${SNAPSHOT_FILE}

#If it's Sunday - we delete the initial metadata file and archives
if [ $DAY = "4" ]; then
 NUM="0"
 mkdir -p ${LAST_WEEK}
 rm -rf /mnt/sdb1/backups/all_system/last_week/*
 mv /mnt/sdb1/backups/all_system/weekly/* ${LAST_WEEK}/
 rm -rf ${SNAPSHOT_FILE_0}
else
 NUM=$DAY
fi

#If there is initial metadata, copy it
if [ -f ${SNAPSHOT_FILE_0} ]; then 
	 cp ${SNAPSHOT_FILE_0} ${SNAPSHOT_FILE}
fi

# Backup server dirs
# You can remove option --ignore-failed-read
$TAR zcfp ${BACKUPDIR}/${BFILE} --exclude-from=${EXCLUDE_CONF} --listed-incremental=${SNAPSHOT_FILE} --ignore-failed-read --one-file-system -C / *

$CRONTAB -l > $BACKUPDIR/crontab_$NOW

#If it's Sunday, create an initial copy of the metadata
if [ $DAY = "4" ]; then 
	 cp ${SNAPSHOT_FILE} ${SNAPSHOT_FILE_0}
fi

# Log backup end time in /var/log/messages
$LOGGER "$0: *** ${BKDIR} Backup Ended @ $(date) ***"

