#!/bin/sh

test_description="Test Agave app VCF processing"

. ./lib/sharness/sharness.sh

# grab variables from config file
. ../../../conf/config.sh

# sharness sets $HOME to the temp directory so link from $USER_HOME
ln -s "$USER_HOME/.agave" "$HOME"

VCF_JOB_TEMPLATE="../templates/deploy-vcf.jsonx"
VCF_JOB_BN=$(basename $VCF_JOB_TEMPLATE .jsonx)
VCF_JOB_FILE="$VCF_JOB_BN.json"

# generate job file
sed -e "s|@@DATESTAMP@@|${DATESTAMP}|g" \
    -e "s|@@APP_ID@@|${APP_ID}|g" \
    -e "s|@@ARCHIVE_PATH@@|${ARCHIVE_PATH}|g" \
    -e "s|@@EMAIL@@|${EMAIL}|g" "$VCF_JOB_TEMPLATE" > "$VCF_JOB_FILE"

test_expect_success "successfully generate vcf job file" '
    test -s $VCF_JOB_FILE
'

test_expect_success "submit and run deploy vcf job" '
    jobs-submit -W -F $VCF_JOB_FILE >job_output 2>&1
'

job_id=$(sed -n 's/Successfully submitted job \(.*\)/\1/p' job_output)
test_expect_success "job successfully finished" '
    [[ $(jobs-status $job_id) = "FINISHED" ]]
'

test_done
