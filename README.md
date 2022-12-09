# conjur-ansible-ara-demo

This is a demo based on containers simulating an environment with [CyberArk Conjur](https://www.conjur.org), [Ansible](https://www.ansible.com) and [ARA](https://ara.readthedocs.io):

![img](assets/img/infra.jpg?raw=true)

## Features
To better simulate the real target environment the demo has the following features:
- no authentication with ssh keys
- password rotation
- internal CA
- TLS certificates signed by the internal CA
- network segmentation

## Requirementes
- docker
- docker-compose-plugin

## Infrastructure
Conjur:
- one frontend server (conjur-proxy)
- one backend server (conjur-server)
- one database server (conjur-database)

Ansible:
- one ansible master (ansible-master)
- three ansible targets (ansible-target[1-3])
  
ARA:
- one ARA server with local db (ansible-ara)


## Getting started
Clone the repository and move into the new directory:
```
$ git clone https://github.com/camandel/conjur-ansible-ara-demo
$ cd conjur-ansible-ara-demo
```
Create and configure the enviroment:
```
$ ./setup-all.sh
```
Now the environment is ready to use:
```
$ docker ps
CONTAINER ID   IMAGE                                   COMMAND                  CREATED         STATUS         PORTS                    NAMES
980ac95db912   conjur-client                           "sleep infinity"         4 minutes ago   Up 4 minutes                            conjur-client
127f43638e68   nginx:1.20-alpine                       "/docker-entrypoint.…"   4 minutes ago   Up 4 minutes   80/tcp                   conjur-proxy
9632b8300b44   ansible-base                            "/usr/sbin/sshd -D"      5 minutes ago   Up 4 minutes   22/tcp                   ansible-target1
86e663f94540   ansible-base                            "/usr/sbin/sshd -D"      5 minutes ago   Up 4 minutes   22/tcp                   ansible-target2
934ab20ad478   ansible-master                          "/usr/sbin/sshd -D"      5 minutes ago   Up 4 minutes   0.0.0.0:2222->22/tcp     ansible-master
1916a7c7ea53   ansible-base                            "/usr/sbin/sshd -D"      5 minutes ago   Up 5 minutes   22/tcp                   ansible-target3
9f840bc6e4c0   cyberark/conjur:1.17.2-2330             "conjurctl server"       5 minutes ago   Up 4 minutes   80/tcp                   conjur-server
5c4b5caa25da   quay.io/recordsansible/ara-api:latest   "bash -c '/usr/local…"   5 minutes ago   Up 5 minutes   0.0.0.0:8000->8000/tcp   ansible-ara
6bd9ca308d48   postgres:14-alpine                      "docker-entrypoint.s…"   5 minutes ago   Up 5 minutes   5432/tcp                 conjur-database
```
Run the test playbook:
```
$ ./run-playbook.sh
```
Simulate password rotation and re-run the playbook:
```
$ ./password-rotation.sh
$ ./run-playbook.sh
```
Once the environment has been configured (do it **only** the first time) it can be managed with `docker compose` command:
```
$ docker compose [stop/start/restart]
```
## Examples
Every container can be accessed with `docker exec` command but **ansible-master** and **ansible-ara** have also ports exposed on your host.

Open a terminal to connect to ansible-master (password is `ansiblelab`):
```
$ ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2222 root@localhost 
root@ansible-master ~]# cd /opt/ansible-lab/
[root@ansible-master ansible-lab]# ansible-playbook -i inventory ping.yml
<...>
[root@ansible-master ansible-lab]# ara playbook list
<...>
```
Use a browser to view ARA web interface:
```
http://localhost:8000
```
## Known problems
### New certificates
If certificates have been updated you need to update some images and configuration files:
```
$ ./generate-certs.sh
$ DOCKER_BUILDKIT=0 docker compose up -d --build ansible-master
$ ./setup-ansible.sh
$ ./setup-conjur.sh
$ docker compose restart conjur-proxy conjur-client ansible-master
```
### Error 502 Bad Gateway
Sometimes during conjur restarts it doesn't automatically delete the pid file:
```
$ docker compose exec conjur-server /opt/conjur-server/tmp/pids/server.pid
$ docker compose restart conjur-server 

```
## Clean-up
To clean-up the whole environment (volumes included) run these commands:
```
$ docker compose down --volumes
$ rm admin.out master.out
```