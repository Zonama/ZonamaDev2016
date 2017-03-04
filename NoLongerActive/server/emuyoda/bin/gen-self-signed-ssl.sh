#!/bin/bash
#
# gen-self-signed-ssl.sh - Generate a new self-signed SSL cert for the server.
#
# Author: Lord Kator <lordkator@swgemu.com>
#
# Created: Sun Jan 24 19:47:06 EST 2016
#
IP=$(cat ~/.force_ip || echo '127.0.0.1')
set -x
cd ~/server/openresty/nginx/conf
rm -f self-signed-ssl.*
openssl req -nodes -newkey rsa:2048 -keyout self-signed-ssl.key -out self-signed-ssl.csr -subj "/C=NB/ST=Naboo/L=Theed/O=Imperial Empire, Inc./OU=Imperial Intelligence/CN="${IP}
openssl x509 -req -days 3650 -in self-signed-ssl.csr -signkey self-signed-ssl.key -out self-signed-ssl.crt
~/server/openresty/nginx/sbin/nginx -s stop
sleep 5
~/server/openresty/nginx/sbin/nginx
exit 0
