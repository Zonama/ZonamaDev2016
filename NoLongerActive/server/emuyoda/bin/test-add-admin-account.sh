#!/bin/bash
#
# test-add-admin-account.sh - Add an admin account
#
# Author: Lord Kator <lordkator@swgemu.com>
#
# Created: Fri Jan 22 08:40:26 EST 2016
#

AUTH_TOKEN=$( (cat ~/server/emuyoda/yoda-config.lua;echo 'print(yodaSecret)')|lua -)

tmpuser=$(mktemp -u yodatestXXXX)

mysql swgemu -e 'delete from accounts where username like "yodatest%"'

trigger=$(mktemp /tmp/test-add-admin-account-trigger-XXXXX)

for i in $(seq 1 20)
do
    echo "** Spawn sub-process $i **"
    (
    while [ -f $trigger ];
    do
	:
    done
    date '+%c %N'
    curl -s -X POST \
	-H "Content-Type: application/json" \
	-H 'authorization: '${AUTH_TOKEN} \
	-d '{ "account": { "username":"'${tmpuser}'","password":"lukeImURFather", "admin_level": 15 } }' \
	'http://127.0.0.1:44480/api/account/' | python -m json.tool
    )&
done

echo "** synchronize **"
sleep 2

echo "** launch **"
rm -f $trigger

echo "** wait for completion **"
wait

mysql swgemu -ve 'select * from accounts'

cnt=$(mysql swgemu -BN -e 'select count(*) from accounts where username like "'${tmpuser}'"')

if [ "$cnt" -ne 1 ]; then
    echo "** TEST FAILED, Found $cnt instances of ${tmpuser}"
    exit 1
fi

mysql swgemu -ve 'delete from accounts where username = "'${tmpuser}'";'

echo "** SUCCESS **"

exit 0
