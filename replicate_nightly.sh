#! /bin/bash

# postgresql commands
PGDUMP=/usr/lib/postgresql/12/bin/pg_dump
PSQL=/usr/lib/postgresql/12/bin/psql

# database host to replicate from
REMOTE_HOST=172.31.0.2
# port to connect to database
REMOTE_PORT=5432
# database to replicate from
REMOTE_DB=ivdb
# database to replicate to
LOCAL_DB=ivdb
# tables to replicate
TABLES=(t1 t2)
# user to perform a remote dump
REMOTE_USER=iv

# dump directory
DUMP_DIR=/var/lib/postgresql/dump/
# dump filename
DUMP_FILE=$DUMP_DIR$(date "+%Y-%m-%d.remote.sql")
# keep dumps for this many days
DUMP_LIFETIME=7

# file with password hash and encryption key
SECRET_FILE=/var/lib/postgresql/.secret


set -e


echo dropping local tables...
DUMP_TABLES=""
for TABLE in ${TABLES[*]}
do
  DUMP_TABLES+="-t ${TABLE} "
  ($PSQL $LOCAL_DB -c "drop table if exists ${TABLE}")
done


echo dumping remote tables...
source $SECRET_FILE
export PGPASSWORD=$(echo $HASH | openssl enc -base64 -d -aes-256-cbc -pass pass:$KEY)
($PGDUMP -h $REMOTE_HOST -p $REMOTE_PORT -U $REMOTE_USER $REMOTE_DB $DUMP_TABLES > $DUMP_FILE)
echo $DUMP_FILE created


echo creating local tables...
($PSQL $LOCAL_DB -f $DUMP_FILE)


echo removing old backup files...
find $DUMP_DIR -mindepth 1 -mtime $DUMP_LIFETIME -print0 | xargs -0r rm -rfv


echo finished successfully!