#!/bin/bash

source ./common.sh

check_root

dnf install mysql-server -y &>>$LOG_FILE
validate $? "Installing MySQL server"

systemctl enable mysqld &>>$LOG_FILE
validate $? "Enabling MySQL server"

systemctl start mysqld
validate $? "Starting MySQL server"

mysql_secure_intallation --set-root-pass RoboShop@1 &>>$LOG_FILE
validate $? "Setting root password"

total_time