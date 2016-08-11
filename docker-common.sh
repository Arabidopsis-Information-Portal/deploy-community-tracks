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

MYUID=$(id -u "$USER")
STAMP=$(date +%s)
DOCKER_APP_CONTAINER="app-$STAMP"
ENVIRONMENT="--env-file ./env.list"
# ENVIRONMENT=""
HOST_OPTS="--net=none -m=2g -u=$MYUID"

# Docker build

DOCKER_IMAGE=$(docker images -q "${DOCKER_APP_IMAGE}:latest")
BUILD_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "${DOCKER_IMAGE}" ] || [ "${DOCKER_FORCE_REBUILD}" == 1 ];
then
	docker build -t "${DOCKER_APP_IMAGE}" "${BUILD_DIR}"
fi

# App container macro
export DOCKER_APP_RUN
DOCKER_APP_RUN="docker run ${HOST_OPTS} -v $(pwd):${HOST_SCRATCH}:rw -w ${HOST_SCRATCH} ${ENVIRONMENT} \
	--name ${DOCKER_APP_CONTAINER} ${DOCKER_APP_IMAGE} "
echo "$DOCKER_APP_RUN"

## <- NO USER-SERVICABLE PARTS INSIDE
