#!/bin/bash

IMAGENAME=$1
TOOLVERSION=$2
COMMAND=$3

if [ -z "$COMMAND" ]; then COMMAND="build"; fi

function die {
	die "$1"
	exit 1
}

DOCKER_INFO=$(docker info > /dev/null)
if [ $? -ne 0 ] ; then die "Docker not found or unreachable. Exiting." ; fi

if [ "$COMMAND" == 'build' ];
then
	docker build --rm=true -t "araport/${IMAGENAME}:${TOOLVERSION}" .
	if [ $? -ne 0 ] ; then die "Error on build. Exiting." ; fi

	IMAGEID=$(docker images -q  "araport/${IMAGENAME}:${TOOLVERSION}")
	if [ $? -ne 0 ] ; then die "Can't find image araport/${IMAGENAME}:${TOOLVERSION}. Exiting." ; fi

	docker tag "${IMAGEID}" "araport/${IMAGENAME}:latest"
	if [ $? -ne 0 ] ; then die "Error tagging with 'latest'. Exiting." ; fi
fi


if [ "$COMMAND" == 'release' ];
then
	docker push "araport/${IMAGENAME}:${TOOLVERSION}" && docker push "araport/${IMAGENAME}:latest"

	if [ $? -ne 0 ] ; then die "Error pushing to Docker Hub. Exiting." ; fi
fi

if [ "$COMMAND" == 'clean' ];
then
	docker rmi -f "araport/${IMAGENAME}:${TOOLVERSION}" && docker rmi -f "araport/${IMAGENAME}:latest"

	if [ $? -ne 0 ] ; then die "Error deleting local images. Exiting." ; fi
fi
