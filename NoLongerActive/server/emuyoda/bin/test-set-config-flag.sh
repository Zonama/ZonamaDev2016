#!/bin/bash
#
# test-set-config-flag.sh - Test setting a emu.yoda.flag via API
#
# Author: Lord Kator <lordkator@swgemu.com>
#
# Created: Wed Feb 24 06:27:00 EST 2016
#

AUTH_TOKEN=$( (cat ~/server/emuyoda/yoda-config.lua;echo 'print(yodaSecret)')|lua -)

post_flag() {
    result=$(curl -s -X PUT \
	-H "Content-Type: application/json" \
	-H 'authorization: '${AUTH_TOKEN} \
	-d '{ "config": { "yoda": { "flags": { "'"${1}"'": '"${2}"' } } } }' \
	'http://127.0.0.1:44480/api/config/')

    echo "$1=$2"

    echo $result | python -m json.tool
}

get_config() {
    curl -s -H 'authorization: '${AUTH_TOKEN} 'http://127.0.0.1:44480/api/config/' | python -m json.tool
}

post_flag "yoda_test_flag" "true"
post_flag "../../../../../../../etc/passwd" "true"
get_config
post_flag "yoda_test_flag" "false"
post_flag "passwd" "false"
get_config
