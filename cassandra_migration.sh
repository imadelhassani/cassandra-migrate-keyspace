#!/bin/bash

# Exporting python and dsbulk
export PATH=/dsbulk-1.8.0/bin:$PATH
export PYTHONIOENCODING=utf-8

operation=$1
keyspace_n=$2
user_auth=$3
pass_auth=$4
bkp_name=$5

if [ "$operation" == "export" ]; then
    # Export data
    # Getting table names
    cqlsh -u $user_auth -p $pass_auth -e "SELECT table_name FROM system_schema.tables WHERE keyspace_name = '${keyspace_n}';" > tables.file

    # Stocking in file and cleaning
    sed 's/^[ \t]*//' tables.file > tables.file1
    sed -e '1,3d;$d' tables.file1 > tables.file.tmp
    sed -e '$d' tables.file.tmp > tables.file

    # Remove tmp files
    rm tables.file.tmp tables.file1

    cat tables.file | while read line
    do
        dsbulk unload -u $user_auth -p $pass_auth -url ${bkp_name}/${line}_csv -k $keyspace_n -t $line -header true
    done

    echo "Dump keyspace and table creation instruction"
    cqlsh -e "desc \"${keyspace_n}\";" > "${bkp_name}/${keyspace_n}.sql" -u $user_auth -p $pass_auth

    echo "Create tar file: ${keyspace_n}.tar.gz"
    tar -czf ${keyspace_n}.tar.gz $bkp_name

elif [ "$operation" == "import" ]; then
    # Import data
    tar_file=$2
    keyspace=$(basename "${tar_file}" ".tar.gz")

    tar -xvzf "${tar_file}"

    echo "adding request timeout"
    cqlsh -u $user_auth -p $pass_auth -e --request-timeout=6000
    echo "Drop keyspace ${keyspace}"
    cqlsh -u $user_auth -p $pass_auth -e "drop keyspace \"${keyspace}\";"

    echo "Create empty keyspace: ${keyspace}"
    cat "${bkp_name}/${keyspace}.sql" | cqlsh -u $user_auth -p $pass_auth

    for dir in "${bkp_name}/"*/;
    do
        str=$dir
        str2=$(echo $str | sed 's|^[^/]*\(/[^/]*/\).*$|\1|')
        table_n=$(echo $str2 | sed 's/^\///;s/\// /g')
        table_n2=${table_n::-5}

        FILES=${dir}*
        for f in $FILES
        do
            dsbulk load -u $user_auth -p $pass_auth -url $f -k $keyspace -t $table_n2 --dsbulk.connector.csv.maxCharsPerColumn 900000 -header true -logDir /tmp/logs
        done
    done
else
    echo "Invalid operation. Use 'export' or 'import'."
fi

