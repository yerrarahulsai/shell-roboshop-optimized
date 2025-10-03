#!/bin/bash

source ./common.sh
app_name=frontend

check_root
nginx_setup

systemctl enable nginx &>>$LOG_FILE    
validate $? "Enabling Nginx"

systemctl start nginx &>>$LOG_FILE
validate $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
validate $? "Removing Old code"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
validate $? "Downloading frontend"

cd /usr/share/nginx/html

unzip /tmp/frontend.zip
validate $? "Unzipping frontend"

rm -rf /etc/nginx/nginx.conf

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
validate $? "Copying Nginx configuration"

systemctl restart nginx
validate $? "Restarting Nginx"

total_time
