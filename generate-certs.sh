#!/bin/bash

# Create dirs
[ -d certs/ca ] || mkdir certs/ca
[ -d certs/servers ] || mkdir certs/servers

# Private key for CA
openssl genrsa -out certs/ca/ca.key 4096

# Pub key for CA
openssl req -x509 -new -nodes -key certs/ca/ca.key -days 1825 -out certs/ca/ca.crt -config certs/config/ca.conf

# Certificate Req for server
openssl req -new -nodes -keyout certs/servers/conjur-proxy.key -out certs/servers/conjur-proxy.csr -config certs/config/conjur-proxy.conf

# Show CRS
openssl req -in certs/servers/conjur-proxy.csr -noout -text -nameopt sep_multiline

# Gen signed pub key for server
openssl x509 -req -in certs/servers/conjur-proxy.csr -CA certs/ca/ca.crt -CAkey certs/ca/ca.key -CAcreateserial -out certs/servers/conjur-proxy.crt -days 1825 -extfile certs/config/conjur-proxy_ext.conf -sha256

# Show CRT
openssl x509 -text -in certs/servers/conjur-proxy.crt -noout

# Verify a Certificate was Signed by a CA
openssl verify -verbose -CAfile certs/ca/ca.crt certs/servers/conjur-proxy.crt

