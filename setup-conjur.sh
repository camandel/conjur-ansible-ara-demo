#!/bin/sh

API_KEY="$(grep API admin.out | cut -d: -f2 | tr -d ' \r\n')"
cat > conjur/client/.netrc << EOF
machine https://conjur-proxy/authn
  login admin
  password $API_KEY
EOF
chmod 600 conjur/client/.netrc