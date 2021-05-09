#!/bin/bash
#ENV=/root/.bashrc
export $(cat /root/.env | xargs) #This file contains the variable MYSQLPASSWORD
NOW=$(date +"%F"_"%H"-"%M")
BACKUPDIR="/mnt/sdb1/backups/nextcloud/"
MYSQLDB="nextcloud"
MYSQLUSER="nextcloud"
TARDIR="www"
CDDIR="/var"

# Paths for binary files
TAR="/bin/tar"
MYSQLDUMP="/usr/bin/mysqldump"
GZIP="/bin/gzip"
SCP="/usr/bin/scp"
SSH="/usr/bin/ssh"
LOGGER="/bin/logger"
FIND="/usr/bin/find"

# DOMAIN - Is folder www as WWW for name backup file
DOMAIN="WWW"
# Store backup path
BACKUP="/mnt/sdb1/backups/nextcloud/"
LAST_WEEK="$BACKUP/last_week"
# Log backup start time in /var/log/messages
$LOGGER "$0: *** ${DOMAIN} ${BKDIR} Backup started @ $(date) ***"

#Get the number of the day of the month
DAY=$(date +%u)

SNAPSHOT_FILE_0="$BACKUP/snapshot_0.snar"
SNAPSHOT_FILE="$BACKUP/snapshot.snar"

# make sure backup directory exists
[ ! -d $BACKUP ] && mkdir -p ${BACKUP}

# Backup names
BFILE="$DOMAIN.$NOW.tar.gz"
MFILE="$DOMAIN.$NOW.mysql.sq.gz"


#Removing the current metadata
rm -rf ${SNAPSHOT_FILE}
#If it's Sunday - we delete the initial metadata file and archives
if [ $DAY = "04" ]; then
         NUM="0"
         rm -rf ${LAST_MONTH}
	 mkdir -p ${LAST_MONTH}
         mv ${BACKUP}/${DOMAIN}* ${LAST_MONTH}/
         rm -rf ${SNAPSHOT_FILE_0}
else
         NUM="$DAY"
fi

#If there is initial metadata, copy it
if [ -f ${SNAPSHOT_FILE_0} ]; then
  cp ${SNAPSHOT_FILE_0} ${SNAPSHOT_FILE}
fi

# Backup MySQL
$MYSQLDUMP  -u ${MYSQLUSER} -h localhost -p${MYSQLPASSWORD} ${MYSQLDB} | $GZIP -9 > ${BACKUP}/${MFILE}

# Backup websever dirs
$TAR  --listed-incremental=${SNAPSHOT_FILE} -zcvf ${BACKUP}/${BFILE} -C ${CDDIR} "${TARDIR}"

#If it's Sunday, create an initial copy of the metadata
if [ $DAY = "04" ]; then
         cp ${SNAPSHOT_FILE} ${SNAPSHOT_FILE_0}
fi

# Log backup end time in /var/log/messages
$LOGGER "$0: *** ${DOMAIN} ${BKDIR} Backup Ended @ $(date) ***"
