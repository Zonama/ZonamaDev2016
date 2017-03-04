#!/bin/bash
#
# test-get-config.sh - Get server config
#
# Author: Lord Kator <lordkator@swgemu.com>
#
# Created: Fri Jan 22 08:46:30 EST 2016
#

AUTH_TOKEN=$( (cat ~/server/emuyoda/yoda-config.lua;echo 'print(yodaSecret)')|lua -)

curl -s -H 'authorization: '${AUTH_TOKEN} 'http://127.0.0.1:44480/api/config/' | python -m json.tool
