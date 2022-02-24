#!/bin/sh
docker-compose exec ansible-master bash -c "source /etc/profile.d/ara.sh && ansible-playbook ping.yml"
