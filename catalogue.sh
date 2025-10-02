#!/bin/bash

source ./common.sh
app_name=catalogue # When we do sourcing we can access variables from other file

check_root
app_setup
nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mmongo.repo
validate $? "Copying Mongo Repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
validate $? "Install MongoDB client"

INDEX=$(mongosh mongodb.daws86s.fun --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Load $app_name products"
else
    echo -e "$app_name products already loaded ... $Y SKIPPING $N"
fi

app_restart
total_time