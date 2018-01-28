#!/bin/bash

# exec 1> >(logger -s -t $(basename $0)) 2>&1

# If no env var for FTP_USER has been specified, use 'admin':
if [ "$FTP_USER" = "**String**" ]; then
    export FTP_USER='admin'
fi

# If no env var has been specified, generate a random password for FTP_USER:
if [ "$FTP_PASS" = "**Random**" ]; then
    export FTP_PASS=`cat /dev/urandom | tr -dc A-Z-a-z-0-9 | head -c${1:-16}`
fi

# Do not log to STDOUT by default:
if [ "$LOG_STDOUT" = "**Boolean**" ]; then
        export LOG_STDOUT=''
else
        export LOG_STDOUT='Yes.'
fi

# Create home dir and update vsftpd user db:
mkdir -p "/home/vsftpd/${FTP_USER}"
chmod 770 -R /home/vsftpd
chown -R ftp. /home/vsftpd

echo -e "${FTP_USER}\n${FTP_PASS}" > /home/vsftpd/virtual_users.txt
/usr/bin/db_load -T -t hash -f /home/vsftpd/virtual_users.txt /home/vsftpd/virtual_users.db

# Create a banner file
echo "vsftpd running on `uname -n`" >/home/vsftpd/banner

# Set passive mode parameters:
if [ "$PASV_ADDRESS" = "**IPv4**" ]; then
    export PASV_ADDRESS=$(/sbin/ip route|awk '/default/ { print $3 }')
fi

echo "pasv_address=${PASV_ADDRESS}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_max_port=${PASV_MAX_PORT}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_min_port=${PASV_MIN_PORT}" >> /etc/vsftpd/vsftpd.conf
# Get log file path
export LOG_FILE=`grep vsftpd_log_file /etc/vsftpd/vsftpd.conf|cut -d= -f2`

# /usr/bin/ln -sf /dev/stdout $LOG_FILE

echo	SERVER SETTINGS
echo	---------------
echo	· FTP User: $FTP_USER
echo	· FTP Password: $FTP_PASS
echo	· Log file: $LOG_FILE
echo 

# Run vsftpd:
echo vsftpd.conf
echo ===========
cat /etc/vsftpd/vsftpd.conf
echo
echo run vsftp with /etc/vsftp/vsftpd.conf
date

touch $LOG_FILE
tail -f $LOG_FILE &

/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf 

date
