#!/bin/bash

cp samples/arabidopsis_thaliana.incl_consequences.vcf.gz . && gunzip arabidopsis_thaliana.incl_consequences.vcf.gz

# generate dummy ID in lieu of an Agave job ID
UUID4=$(curl -skq "https://www.uuidgenerator.net/api/version4")

export AGAVE_JOB_ID=${UUID4}
export AGAVE_JOB_OWNER=vaughn
export AGAVE_BEARER_TOKEN=19aaedef4af51ca537e9a795364d86c

export DOCKER_FORCE_REBUILD=1

export GDF_FILE=arabidopsis_thaliana.incl_consequences.vcf
export DESCRIPTION="Arabidopsis variation data"
export GENOME_VERSION=araport11

bash template.bashx
