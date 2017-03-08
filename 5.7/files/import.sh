#!/bin/bash

# if a sql dump has been mounted into /db then import it
dbfile="/db/data.sql"
if [ -f "$dbfile" ]; then
    echo "importing $dbfile"
    mysql -u root -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE -e "SOURCE $dbfile"
fi
