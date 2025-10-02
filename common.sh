#!/bin/bash

USER_ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$(pwd)
MONGODB_HOST=mongodb.rahulsai.com
MYSQL_HOST=mysql.rahulsai.com
START_TIME=$(date +%s)

mkdir -p $LOGS_FOLDER
echo "Script started executing at $(date)" | tee -a $LOG_FILE

check_root(){
    if [ $USER_ID -ne 0 ]; then
        echo "Error: Please run this script with root privilege"
        exit 1
    fi
}

validate(){
    if [ $1 -ne 0 ]; then   
        echo -e "$2...$R Failure $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2...$G Success $N" | tee -a $LOG_FILE
    fi
}

nodejs_setup(){
    dnf disable nodejs -y &>>$LOG_FILE
    validate $? "Disabling NodeJS"

    dnf enable nodejs:20 -y &>>$LOG_FILE
    validate $? "Enabling NodeJS"

    dnf install nodejs -y &>>$LOG_FILE
    validate $? "Installing NodeJS"

    npm install &>>$LOG_FILE
    validate $? "Installing Dependencies"
}

java_setup(){
    dnf install maven -y &>>$LOG_FILE
    validate $? "Installing Maven"

    mvn clean package &>>$LOG_FILE
    validate $? "Installing depedencies"

    mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
    validate $? "Renaming the artifact"
}

python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    validate $? "Installing Python"

    pip3 install -r requirements.txt
    validate $? "Installing dependencies"

}
nginx_setup(){
    dnf module disable nginx -y &>>$LOG_FILE
    validate $? "Disabling Nginx"

    dnf module enable nginx:1.24 -y &>>$LOG_FILE
    validate $? "Enabling Nginx"

    dnf install nginx -y &>>$LOG_FILE
    validate $? "Installing Nginx"

}
app_setup(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
        validate $? "Creating system user"
    else
        echo -e "User already exists...$Y Skipping $N"
    fi

    mkdir -p /app
    validate $? "Creating App directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    validate $? "Downloading Application"

    cd /app
    validate $? "Changing to app directory"

    rm -rf /app/*
    validate $? "Removing old code"

    unzip /tmp/$app_name.zip
    validate $? "Unzipping application"
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    validate $? "Copying systemctl service"

    systemctl daemon-reload
    systemctl enable $app_name &>>$LOG_FILE
    validate $? "Enabling $app_name"
}

app_restart(){
    systemctl restart $app_name
    validate $? "Restarting $app_name"
}

total_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME-$START_TIME))
    echo -e "Script executed in $Y $TOTAL_TIME seconds $N"
}