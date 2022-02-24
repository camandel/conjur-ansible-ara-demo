#!/bin/sh

# generate certificates
[ -f certs/ca/ca.key ] || ./generate-certs.sh

# start infrastructure
docker-compose up -d

# setup conjur server
docker-compose exec conjur-server conjurctl wait
docker-compose exec conjur-server conjurctl account create demo | tee admin.out

# setup conjur client
./setup-conjur.sh

# setup ansible policy
docker-compose exec conjur-client conjur policy load --replace root /policies/root.yml | tee master.out

# change password
./password-rotation.sh

# setup ansible master
./setup-ansible.sh
