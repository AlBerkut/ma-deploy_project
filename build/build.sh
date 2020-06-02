#!/bin/bash

version="0.2.4"

user=`echo $USER`

baseRepo="git@github.com:AlBerkut/MA.-Project.git"
frontAdminRepo="git@github.com:AlBerkut/ma_project_admin.git"
gitBranch="master"

buildDirPath=`pwd`
dirPath="/home/$user/Documents"
pathToEnv="${dirPath}/Projects/2019-2020_MoC/envDir/"
mkdir "${dirPath}/workDir/"
workDirPath="${dirPath}/workDir/"

baseRepoPath="${workDirPath}/MA.-Project"
	apiPath="${baseRepoPath}/api/"
	baseFrontPath="${baseRepoPath}/front-end/"

adminFrontPath="${workDirPath}/ma_project_admin/"

cd $workDirPath && git clone $baseRepo
cd $workDirPath && git clone $frontAdminRepo

###################################################################################
# Building Apps
###################################################################################
cd $baseRepoPath && git checkout $gitBranch

cd $apiPath
echo "#########################"
echo "#   Building backend    #"
echo "#########################"
cp "$pathToEnv/base.env" "./" && mv "base.env" ".env"
npm install

cd $baseFrontPath
echo "#########################"
echo "#  Building baseFront   #"
echo "#########################"
npm install
npm run build

cd $adminFrontPath && git checkout $gitBranch
echo "#########################"
echo "#  Building adminFront  #"
echo "#########################"
npm install
npm run build

###################################################################################
# Building Images
###################################################################################

echo "#########################"
echo "#    Building Images    #"
echo "#########################"
cd $buildDirPath
cp Dockerfile-nginx $workDirPath
cp Dockerfile-api $workDirPath
cp Dockerfile-admfront $workDirPath
cp Dockerfile-frontend $workDirPath
cp -r conf/ $workDirPath
cp docker-compose.yml $workDirPath

cd $workDirPath
docker-compose build --no-cache

nginx="alberkut/ma-project_nginx:latest"
frontend="alberkut/ma-project_frontend:latest"
admfront="alberkut/ma-project_admfront:latest"
api="alberkut/ma-project_api:latest"

nginxImageID=`docker images | grep "workdir_nginx" | awk '{print $3}'`
frontendImageID=`docker images | grep "workdir_frontend" | awk '{print $3}'`
admFrontImageID=`docker images | grep "workdir_admfront" | awk '{print $3}'`
apiImageID=`docker images | grep "workdir_api" | awk '{print $3}'`

# Push Nginx
docker tag $nginxImageID $nginx && docker push $nginx
# Push MySql
docker tag $admFrontImageID $admfront && docker push $admFront
# Push Frontend
docker tag $frontendImageID $frontend && docker push $frontend
# Push API
docker tag $apiImageID $api && docker push $api

# Delete workDir
rm -rf $workDirPath
