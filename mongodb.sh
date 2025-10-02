#!/bin/bash

source ./common.sh #common.sh script starts executing
 
check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "Coying Mongo Repo"

dnf install mongodb-org -y &>>$LOG_FILE
validate $? "Installing MongoDB"

systemctl enable mongod &>>$LOG_FILE
validate $? "Enabling MongoDB"

systemctl start mongod
validate $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "Allowing remote connections to MongoDB"

systemctl restart mongod
validate $? "Restarting MongoDB"

total_time