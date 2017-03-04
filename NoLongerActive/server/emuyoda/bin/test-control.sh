#!/bin/bash
#
# test-control - Test Yoda API control commands
#
# Author: Lord Kator <lordkator@swgemu.com>
#
# Created: Fri Jan 22 08:28:49 EST 2016
#

AUTH_TOKEN=$( (cat ~/server/emuyoda/yoda-config.lua;echo 'print(yodaSecret)')|lua -)

curl -s -H 'authorization: '${AUTH_TOKEN} 'http://127.0.0.1:44480/api/control?command='$1 | python -m json.tool
