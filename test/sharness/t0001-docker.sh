#!/bin/sh

test_description="Basic Docker Tests"

. ./lib/sharness/sharness.sh

test_expect_success "docker is installed" '
    command -v docker >/dev/null
'

test_expect_success "docker --version works" '
    docker --version >output
'

test_expect_success "docker --version output looks correct" '
    egrep "^Docker version" output
'

export DOCKER_APP_IMAGE="araport/deploy-community-tracks"
export HOST_SCRATCH="/data"
test_expect_success "docker-common is successful" '
    bash ../../../docker-common.sh >output 2>&1
'

test_done
