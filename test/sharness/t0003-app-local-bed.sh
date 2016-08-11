#!/bin/sh

test_description="Test app local GFF processing"

. ./lib/sharness/sharness.sh

# generate dummy ID in lieu of an Agave job ID
UUID4=$(curl -skq "https://www.uuidgenerator.net/api/version4")

export AGAVE_JOB_ID=${UUID4}
export AGAVE_JOB_OWNER=eriksf
export AGAVE_BEARER_TOKEN=19aaedef4af51ca537e9a795364d86c

export DOCKER_FORCE_REBUILD=1

export GDF_FILE=pollen.bed
export DESCRIPTION="Sample pollen data"
export GENOME_VERSION=araport11

OUTPUT_FILE_BASE="pollen-${AGAVE_JOB_OWNER}-${UUID4%?}"

test_expect_success "successfully process BED file" '
    cp ../../../samples/pollen.bed . &&
    bash ../../../template.bashx >output 2>&1
'

test_expect_success "successfully generate sorted bgzip file" '
    test -s $OUTPUT_FILE_BASE.sorted.bed.gz
'

test_expect_success "successfully generate tabix file" '
    test -s $OUTPUT_FILE_BASE.sorted.bed.gz.tbi
'

test_expect_success "successfully generate jbrowse config file" '
    test -s $OUTPUT_FILE_BASE.conf
'

test_done
