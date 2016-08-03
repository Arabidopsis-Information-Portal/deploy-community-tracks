## -> NO USER-SERVICABLE PARTS INSIDE
# Create container with unique but human comprehensible name

if [ -z "${DOCKER_APP_IMAGE}" ];
then
    echo "Error: DOCKER_APP_IMAGE was not defined"
    exit 1
fi
if [ -z "$HOST_SCRATCH" ];
then
    echo "Warning: HOST_SCRATCH was not defined"
    exit 1
fi

TTY=""
# TTY="-t"
MYUID=$(id -u $USER)
STAMP=$(date +%s)
DOCKER_APP_CONTAINER="app-$STAMP"
ENVIRONMENT="--env-file ./env.list"
# ENVIRONMENT=""
HOST_OPTS="--net=none -m=2g -u=$MYUID"

# Docker build
docker build -t ${DOCKER_APP_IMAGE} .

# App container macro
DOCKER_APP_RUN="docker run ${HOST_OPTS} -d -v `pwd`:${HOST_SCRATCH}:rw -w ${HOST_SCRATCH} ${ENVIRONMENT} --name ${DOCKER_APP_CONTAINER} ${DOCKER_APP_IMAGE} "
## <- NO USER-SERVICABLE PARTS INSIDE
