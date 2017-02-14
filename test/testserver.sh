#!/bin/bash

IMAGE="$1"
TAG="$2"
SERVERSTART=0
SERVERCONNECT=0
SUCCESS=false
echo "Starting image with MySQL image $IMAGE:$TAG"
docker run -e MYSQL_ROOT_PASSWORD=rot --name=testserver -p 3306:3306 -d $IMAGE:$TAG
RES=$?
if [ ! $RES = 0 ]; then
	echo "Server start failed with error code $RES"
else
	SERVERSTART=1
fi
echo "Connecting to server..."
if [ $SERVERSTART ];
then
	for i in $(seq 30 -1 0); do
		OUTPUT="$(echo 'SHOW VARIABLES like \'version\';' | mysql -uroot -prot -h127.0.0.1 -P3306)"
		RES=$?
		if [ $RES -eq 0 ]; then
			SERVERCONNECT=1
			break
		fi	
		sleep 1
	done
	if [ $i = 0 ]; then
		echo >&2 "Unable to connect to server."
	fi
fi

if [ $SERVERCONNECT ];
then
	versionregex="version	$VERSION"
	if [[ $OUTPUT =~ $versionregex ]];
	then
		echo "Version check ok"
		SUCCESS=true
	else
		echo "Expected to see version $VERSION. Actual output: $OUTPUT"
	fi
fi

if [ $SUCCESS == true ];
then
	echo "Test passed"
	exit 0
else
	echo "Test failed"
	exit 1
fi

