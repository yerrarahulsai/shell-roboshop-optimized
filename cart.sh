#!/bin/bash

source ./common.sh
app_name=cart

check_root
app_setup
nodejs_setup
systemd_setup
app_restart
total_time