#!/bin/bash
#
# test-login-get-config.sh - Test API login and get config with token
#
# Author: Lord Kator <lordkator@swgemu.com>
#
# Created: Fri Feb 26 06:11:52 EST 2016
#

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

if [ -n "$1" ]; then
    host=$1
    shift
else
    host='127.0.0.1'
fi

host='http://'"${host}"':44480'

result=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{ "auth": { "username":"'"${username}"'","password":"'${password}'" } }' \
    "${host}"'/api/auth/')

if echo $result | python -m json.tool; then
    :
else
    echo "** ERROR: GET ${host}/api/auth/ FAILED=[$result] **"
    exit 1
fi

AUTH_TOKEN=$(echo "$result" | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["response"]["token"]' 2>/dev/null)

echo "Token=[$AUTH_TOKEN]"

if [ -z "${AUTH_TOKEN}" ]; then
    echo "** LOGIN FAILED **"
    exit 2
fi

result=$(curl -s -H 'authorization: '${AUTH_TOKEN} "${host}"'/api/config/')

if echo $result | python -m json.tool; then
    :
else
    echo "** ERROR: GET ${host}/api/config/ FAILED=[$result] **"
    exit 3
fi

