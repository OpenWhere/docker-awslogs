#!/bin/sh

shutdown_awslogs()
{
    echo "Stopping container..."
    kill $(pgrep -f /var/awslogs/bin/aws)
    exit 0
}

trap shutdown_awslogs INT TERM HUP


# [/mnt/logs/access.log]
# datetime_format = %d/%b/%Y:%H:%M:%S %z
# file = /mnt/logs/access.log
# buffer_duration = 5000
# log_stream_name = {instance_id}
# initial_position = start_of_file
# log_group_name = nginx-server

LOGFILE=${AWS_LOGFILE:-"/data/log/*.log"}
LOGFORMAT=${AWS_LOGFORMAT:-"%b %d, %Y %H:%M:%S %p"}
DURATION=${AWS_DURATION:-"5000"}
GROUPNAME=${AWS_GROUPNAME:-"unknown-server"}

cp -f /awslogs.conf.dummy /var/awslogs/etc/awslogs.conf

cat >> /var/awslogs/etc/awslogs.conf <<EOF
[${LOGFILE}]
datetime_format = ${LOGFORMAT}
file = ${LOGFILE}
buffer_duration = ${DURATION}
log_stream_name = {instance_id}
time_zone = UTC
initial_position = start_of_file
log_group_name = ${GROUPNAME}

EOF

touch /var/log/awslogs.log
/var/awslogs/bin/awslogs-agent-launcher.sh &
tail -f /var/log/awslogs.log

wait
