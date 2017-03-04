#!/bin/bash
#
# test-login.sh - Test API login
#
# Author: Lord Kator <lordkator@swgemu.com>
#
# Created: Sun Jan 24 10:45:17 EST 2016
#

AUTH_TOKEN=$( (cat ~/server/emuyoda/yoda-config.lua;echo 'print(yodaSecret)')|lua -)

if [ -n "$1" ]; then
    username=$1
    shift
else
    read -p "Username: " username
fi

if [ -n "$1" ]; then
    password=$1
    shift
else
    read -s -p "Password: " password
fi

result=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{ "auth": { "username":"'"$username"'","password":"'${password}'" } }' \
    'http://127.0.0.1:44480/api/auth/')

echo $result | python -m json.tool

AUTH_TOKEN=$(echo "$result" | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["response"]["token"]')

echo "Token=[$AUTH_TOKEN]"

# Check our auth
result=$(curl -s -H 'authorization: '${AUTH_TOKEN} 'http://127.0.0.1:44480/api/auth/')

echo $result | python -m json.tool
