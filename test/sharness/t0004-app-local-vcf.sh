#!/bin/sh

test_description="Test app local VCF processing"

. ./lib/sharness/sharness.sh

# grab variables from config file
. ../../../conf/config.sh

# generate dummy ID in lieu of an Agave job ID
UUID4=$(curl -skq "https://www.uuidgenerator.net/api/version4")

export AGAVE_JOB_ID=${UUID4}
export AGAVE_JOB_OWNER=${USERNAME}
export AGAVE_BEARER_TOKEN=${BEARER_TOKEN}

export DOCKER_FORCE_REBUILD=1

export GDF_FILE=arabidopsis_thaliana.incl_consequences.vcf
export DESCRIPTION="Arabidopsis variation data"
export GENOME_VERSION=araport11

OUTPUT_FILE_BASE="arabidopsis_thaliana.incl_consequences-${AGAVE_JOB_OWNER}-${UUID4%?}"

test_expect_success "successfully process VCF file" '
    cp ../../../samples/arabidopsis_thaliana.incl_consequences.vcf.gz . &&
    gunzip arabidopsis_thaliana.incl_consequences.vcf.gz &&
    bash ../../../template.bashx >output 2>&1
'

test_expect_success "successfully generate sorted bgzip file" '
    test_must_exist "$OUTPUT_FILE_BASE.sorted.vcf.gz"
'

test_expect_success "successfully generate tabix file" '
    test_must_exist "$OUTPUT_FILE_BASE.sorted.vcf.gz.tbi"
'

test_expect_success "successfully generate jbrowse config file" '
    test_must_exist "$OUTPUT_FILE_BASE.conf"
'

test_done
