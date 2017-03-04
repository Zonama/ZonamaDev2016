#!/bin/bash
#
# test-set-config.sh - Set server config via API
#
# Author: Lord Kator <lordkator@swgemu.com>
#
# Created: Fri Jan 22 08:49:56 EST 2016
#

AUTH_TOKEN=$( (cat ~/server/emuyoda/yoda-config.lua;echo 'print(yodaSecret)')|lua -)

# Set server config (Zones)
curl -s -X PUT \
    -H "Content-Type: application/json" \
    -H 'authorization: 7fe042ae5fe71888ef88ab04c0fdab9e' \
    -d '{ "config": { "emu": { "ZonesEnabled": [ "yavin4", "lok", "tutorial" ] } } }' \
    'http://127.0.0.1:44480/api/config/' | python -m json.tool
