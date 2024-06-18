#!/bin/bash

source /home/dikshyant/airflow/scripts/delete.sh

# Ensure MySQL command is found
# export PATH=$PATH:/usr/bin/mysql

current_date=$(date +"%Y%m%d_%H%M%S")

backupPath="/home/dikshyant/airflow/backup"
mysql_host="localhost"
mysql_port="3306"
db_name="dump"
mysql_pass="airflow_pass"
mysql_user="airflow_user"

# SQL query to get the total size of the database in bytes
SQL_QUERY="SELECT SUM(data_length + index_length) FROM information_schema.tables WHERE table_schema='${db_name}';"

# Execute the SQL query and store the result in a variable
DB_SIZE_BYTES=$(mysql -h ${mysql_host} -P ${mysql_port} -u ${mysql_user} -p${mysql_pass} -sse "${SQL_QUERY}")
DB_SIZE=$(echo "scale=2; ${DB_SIZE_BYTES}/1024^3" | bc)

# Calculate total available space in the system
TOTAL_FREE_SPACE_KB=$(df --output=avail -x tmpfs -x devtmpfs -x squashfs -x overlay -x aufs | awk 'NR>1 {sum += $1} END {print sum}')
# Convert total free space from KB to GB (For 1024 block size)
FREE_SPACE=$(echo "scale=2; ${TOTAL_FREE_SPACE_KB}/1024^2" | bc)

if (( $(echo "${DB_SIZE} < ${FREE_SPACE}" | bc -l) )); then
    start_time=$(date +%s)

    BACKUP_FILE="${backupPath}/${db_name}_${current_date}.sql.gz"
    mysqldump -h ${mysql_host} -P ${mysql_port} -u ${mysql_user} -p${mysql_pass} ${db_name} | gzip > ${BACKUP_FILE}

    deleteFile ${backupPath}

    end_time=$(date +%s)
    elapsed_time=$((end_time - start_time))
    echo "Backup completed in ${elapsed_time} seconds"

    messageOut="Backup Success in location: ${backupPath}|Required Space: ${DB_SIZE}GB, Available Space: ${FREE_SPACE}GB"
else
    messageOut="Backup Failed.|Required Space: ${DB_SIZE}GB, Available Space: ${FREE_SPACE}GB"
fi

echo "$messageOut" #output message for Airflow to pick up
