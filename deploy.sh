#!/bin/bash

user=`echo $USER`

sshKeyFile="/home/$user/.ssh/admin-key.pem"
sshHostURL="ubuntu@3.250.170.88"

nginx="alberkut/ma-project_nginx:latest"
frontend="alberkut/ma-project_frontend:latest"
admfront="alberkut/ma-project_admfront:latest"
api="alberkut/ma-project_api:latest"

cd build/ && bash build.sh

scp -i $sshKeyFile host/docker-compose.yml "${sshHostURL}:~/project/"

ssh -i $sshKeyFile $sshHostURL << EOF
	cd ~/project/
	docker pull $nginx
	docker pull $api
	docker pull $frontend
	docker pull $admfront

	docker-compose down
	docker-compose up -d
EOF

