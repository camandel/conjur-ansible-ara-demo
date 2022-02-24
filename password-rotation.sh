#!/bin/sh

# change passwords
for N in $(seq 3)
do
  PASSWORD=$(openssl rand -base64 32)
  echo "Setting password ${PASSWORD} for ansible-target${N}"
  docker-compose exec conjur-client conjur variable values add root/ansible-target${N}/pass "${PASSWORD}"
  docker-compose exec ansible-target${N} bash -c "echo '${PASSWORD}' | passwd --stdin root"
done
