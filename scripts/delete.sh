#!/bin/bash

function deleteFile(){
    local backupDir=$1
    cd "${backupDir}" || exit

    local file_count
    file_count=$(ls | wc -l)

    if [ "$file_count" -gt 2 ];then
        ls -t | tail -n +3 | xargs rm -- #orders file acc to latest modified date and deletes oldest file
    fi
}

# backupPath="/home/avyuthan-shah/Desktop/F1Intern/WeekendTask/Airflow/sqlDumps"
# deleteFile ${backupPath}

