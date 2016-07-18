#!/bin/sh

USER=$1
PASSWORD=$2
MYSQL_HOST=$3
DBNAME=dsp
tables="user permission role role_permission user user_role"
OUTPUT_DIR="$HOME/chandni-chowk-db-dumps"
FILE_PREFIX=${DBNAME}
FILE_EXT='.sql'
FILE_NAME=${FILE_PREFIX}${FILE_EXT}

if [ $# -ne 3 ]
then
        echo "Usage: mysql_dumps <mysql_user> <mysql_pass>"
        exit 1
fi

sudo mkdir -p ${OUTPUT_DIR}
sudo chmod 777 ${OUTPUT_DIR}
mysqldump -u$USER -p$PASSWORD -h $MYSQL_HOST ${DBNAME} > ${OUTPUT_DIR}/${FILE_NAME}
mysql -u$USER -p${PASSWORD} -h $MYSQL_HOST ${DBNAME} < ${OUTPUT_DIR}/${FILE_NAME}

for table in $tables
do
        filename=${table}.sql
        sudo mysqldump -u$USER -p${PASSWORD} -h $MYSQL_HOST $DBNAME $table > ${OUTPUT_DIR}/$filename
        if [ $? -ne 0 ]
        then
                echo "$db $table dump unsuccessful"
		exit 1
        fi
done

exit 0


