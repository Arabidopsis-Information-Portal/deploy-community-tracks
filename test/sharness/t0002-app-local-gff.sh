#!/bin/sh

test_description="Test app local GFF processing"

. ./lib/sharness/sharness.sh

# grab variables from config file
. ../../../conf/config.sh

# generate dummy ID in lieu of an Agave job ID
UUID4=$(curl -skq "https://www.uuidgenerator.net/api/version4")

export AGAVE_JOB_ID=${UUID4}
export AGAVE_JOB_OWNER=${USERNAME}
export AGAVE_BEARER_TOKEN=${BEARER_TOKEN}

export DOCKER_FORCE_REBUILD=1

export GDF_FILE=uorf_60_araport11.gff
export DESCRIPTION="uORF60 data"
export GENOME_VERSION=araport11

OUTPUT_FILE_BASE="uorf_60_araport11-${AGAVE_JOB_OWNER}-${UUID4%?}"

test_expect_success "successfully process GFF file" '
    cp ../../../samples/uorf_60_araport11.gff . &&
    bash ../../../template.bashx >output 2>&1
'

test_expect_success "successfully generate sorted bgzip file" '
    test_must_exist "$OUTPUT_FILE_BASE.sorted.gff.gz"
'

test_expect_success "successfully generate tabix file" '
    test_must_exist "$OUTPUT_FILE_BASE.sorted.gff.gz.tbi"
'

test_expect_success "successfully generate jbrowse config file" '
    test_must_exist "$OUTPUT_FILE_BASE.conf"
'

test_done
