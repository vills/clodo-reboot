#!/bin/bash

# Simple bash-script to reboot your Clodo's VPS from console.
# Writen by Vil Surkin <vills@clodo.ru>, 2012

CL_VERSION="0.3.0"

# some functions for colorized output
function print_error() {
    echo -e "\033[01;31mERROR!\033[01;00m"
    echo -e "\033[01;31m${1}\033[01;00m"
    exit
}

function print_good() {
    echo -e "\033[01;32m${1}\033[01;00m"
}

if [[ $EUID -ne 0 ]]; then
    print_error "You must be a root user"
fi

# import settings
if [ ! -f ~/.clodo-reboot ]; then
    print_error "You need put your auth data to ~/.clodo-reboot"
else
    . ~/.clodo-reboot
fi


# getting server num from /proc/cmdline
SERVER_NUM=$(cat /proc/cmdline | \
    awk '{ cnt=split($0,str," "); for (i=1;i<=cnt;i++){ if (str[i] ~ /^uos_net/) { split(str[i],vpsnum,"-"); print vpsnum[2] } } }')

# authorizing at ClodoAPI
function auth() {
    if (( $SERVER_NUM > 10000 && $SERVER_NUM < 20000 )); then
        API_LINK="http://api.kh.clodo.ru"
    elif (( $SERVER_NUM > 20000 && $SERVER_NUM < 30000 )); then
        API_LINK="http://api.mn.clodo.ru"
    else
        API_LINK="http://api.clodo.ru"
    fi

    AUTH_DATA="$(curl -I -s -H "X-Auth-User: ${CLODO_USER}" -H "X-Auth-Key: ${CLODO_KEY}" $API_LINK)"
    
    ERR=`echo "$AUTH_DATA" | grep 'Unauthorized'`
    if [ $? -eq 0 ]; then
        print_error "Can't get authorization! Check config ~/clodo-reboot"
    fi

    API_URL=`echo "$AUTH_DATA" | grep 'X-Server-Management-Url' | sed 's/X-Server-Management-Url: \(.*\)\r/\1/'`
    if [ -z "$API_URL" ]; then
        print_error "Can't get API URL"
    fi

    API_TOKEN=`echo "$AUTH_DATA" | grep 'X-Auth-Token' | sed 's/X-Auth-Token: \(\w*\)\r/\1/'`
    if [ -z "$API_TOKEN" ]; then
        print_error "Can't get API TOKEN"
    fi

    return 0
}


#   ===================================
auth


if [ ! $1 ]; then
    REBOOT_REQ="$(curl -I -s -H "X-Auth-Token: ${API_TOKEN}" $API_URL/servers/${SERVER_NUM}/reboot)"
    
    ERR=`echo "$REBOOT_REQ" | grep 'Method Not Allowed'`
    if [ $? -eq 0 ]; then
        print_error "Actions for this server is temporary disabled"
    fi
    
    ERR=`echo "$REBOOT_REQ" | grep 'Bad Request'`
    if [ $? -eq 0 ]; then
        print_error "Ohh... Smthing goes wrong. Please, contact our technical support."
    fi
fi

print_good "Request to ClodoAPI was successfully sent."

print_good "Sleeping for 4 seconds.."
sleep 4

print_good "Init normal server reboot (/sbin/reboot)."
/sbin/reboot
