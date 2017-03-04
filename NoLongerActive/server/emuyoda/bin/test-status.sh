#!/bin/bash
#
# test-status - Test Yoda API status call
#
# Author: Lord Kator <lordkator@swgemu.com>
#
# Created: Fri Jan 22 08:36:39 EST 2016
#

AUTH_TOKEN=$( (cat ~/server/emuyoda/yoda-config.lua;echo 'print(yodaSecret)')|lua -)

curl -s -H 'authorization: '${AUTH_TOKEN} 'http://127.0.0.1:44480/api/status' | python -m json.tool
