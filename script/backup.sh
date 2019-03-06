#!/bin/bash

if [ "`whoami`" != "postgres" ] ;then
    echo "please su to postgres !";
    exit 1;
fi

path="/var/data/backup/pg_phys_backup/"
cd $path

echo $'#!/bin/bash

dbname=$1
dateTime=$2

echo "
$(date +"%Y-%m-%d %H:%M:%S") remove old backup file...
"
find -name "pg_phys_bak_*" -mtime +4 -exec rm -f {} \;

echo "
$(date +"%Y-%m-%d %H:%M:%S") starting backup...
"
psql -h 127.0.0.1 -c "select pg_start_backup(\'$dateTime\');"

echo "
$(date +"%Y-%m-%d %H:%M:%S") tar postgres dir of ${dbname}...
"
tar zcf pg_phys_bak_$dbname\'_\'$dateTime.gz -C /var/data/ postgres --exclude=pg_xlog

echo "
$(date +"%Y-%m-%d %H:%M:%S") ending backup...
"
psql -h 127.0.0.1 -c "select pg_stop_backup();"

echo "
$(date +"%Y-%m-%d %H:%M:%S") scp backup file...
"
#scp pg_phys_bak_* pg-06.d6:/var/data/backup/pg_phys_backup && rm -f pg_phys_bak_*

echo "
$(date +"%Y-%m-%d %H:%M:%S") done.
"
' > do_pg_phys_backup.sh
chmod 700 do_pg_phys_backup.sh

hostname=$(hostname)
hostname=${hostname//-/_}
#dbname=${hostname%%.*}
dbname=${hostname//./_}

#dateTime=$(date +%m%d%H%M)
dateTime=$(psql -h 127.0.0.1 -XAt -c "SELECT to_char(current_timestamp, 'MMDDHH24MI');")

sh -u do_pg_phys_backup.sh $dbname $dateTime  |& tee pg_phys_bak_$dbname'_'$dateTime.log
rm -f do_pg_phys_backup.sh