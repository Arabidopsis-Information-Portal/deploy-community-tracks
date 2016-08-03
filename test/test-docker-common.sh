#!/bin/bash

export DOCKER_APP_IMAGE='araport/deploy-community-tracks'
# You may append a specific versioned tag to the data image, but be warned that will
# restrict the set of queriable public datasets to JUST that release unless
# the tag is 'latest'
# Only change if you need to and know what you're doing
export HOST_SCRATCH='/data'
# In theory, these values can be set in the Agave application's metadata
# then set to invisible so they can't be re-set by end user
# How many concurrent threads to run BLAST*

bash docker-common.sh
