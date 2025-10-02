#!/bin/bash

source ./common.sh

check_root

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? "Copying Repo file"

dnf install rabbitmq-server -y &>>$LOG_FILE
validate $? "Installing RabbitMQ server"

systemctl enable rabbitmq-server &>>$LOG_FILE
validate $? "Enabling RabbitMQ"

systemctl start rabbitmq-server
validate $? "Starting RabbitMQ"

rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
validate $? "Setting Up permissions"

total_time