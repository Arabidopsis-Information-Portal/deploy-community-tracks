#!/bin/bash

IMAGENAME=$1
TOOLVERSION=$2
COMMAND=$3

if [ -z "$COMMAND" ]; then COMMAND="build"; fi

function die {
	echo "$1" 1>&2
	exit 1
}

docker info > /dev/null || die "Docker not found or unreachable. Exiting."

if [ "$COMMAND" == 'build' ];
then
	docker build --rm=true -t "${IMAGENAME}:${TOOLVERSION}" . \
		|| die "Error on build. Exiting."

	IMAGEID=$(docker images -q  "${IMAGENAME}:${TOOLVERSION}") \
		|| die "Can't find image ${IMAGENAME}:${TOOLVERSION}. Exiting."

	docker tag "${IMAGEID}" "${IMAGENAME}:latest" \
		|| die "Error tagging with 'latest'. Exiting."
fi


if [ "$COMMAND" == 'release' ];
then
	( docker push "${IMAGENAME}:${TOOLVERSION}" && docker push "${IMAGENAME}:latest" ) \
		|| die "Error pushing to Docker Hub. Exiting."
fi

if [ "$COMMAND" == 'clean' ];
then
	( docker rmi -f "${IMAGENAME}:${TOOLVERSION}" && docker rmi -f "${IMAGENAME}:latest" ) \
		|| die "Error deleting local images. Exiting."
fi
