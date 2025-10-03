#!/bin/bash

source ./common.sh

check_root

dnf module disable redis -y &>>$LOG_FILE
validate $? "Disabling Redis"

dnf module enable redis:7 -y &>>$LOG_FILE
validate $? "Enabling Redis"

dnf install redis -y &>>$LOG_FILE
validate $? "Installing Redis"

sed -i 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
validate $? "Allowing remote connections to Redis"

systemctl enable redis &>>$LOG_FILE
validate $? "Enabling Redis"

systemctl start redis 
validate $? "Starting Redis"

total_time