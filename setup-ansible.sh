#!/bin/sh

API_KEY=$(grep api_key master.out | cut -d: -f2 | tr -d ' \r\n"')
cat > master/master.identity << EOF
machine https://conjur-proxy/authn
    login host/root/ansible-master
    password $API_KEY
EOF
docker cp master/master.identity ansible-master:/etc/conjur.identity