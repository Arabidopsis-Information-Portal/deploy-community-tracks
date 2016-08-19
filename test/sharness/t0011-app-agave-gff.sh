#!/bin/sh

test_description="Test Agave app GFF processing"

. ./lib/sharness/sharness.sh

# grab variables from config file
. ../../../conf/config.sh

# sharness sets $HOME to the temp directory so link from $USER_HOME
ln -s "$USER_HOME/.agave" "$HOME"

GFF_JOB_TEMPLATE="../templates/deploy-gff.jsonx"
GFF_JOB_BN=$(basename $GFF_JOB_TEMPLATE .jsonx)
GFF_JOB_FILE="$GFF_JOB_BN.json"

# generate job file
sed -e "s|@@DATESTAMP@@|${DATESTAMP}|g" \
    -e "s|@@APP_ID@@|${APP_ID}|g" \
    -e "s|@@ARCHIVE_PATH@@|${ARCHIVE_PATH}|g" \
    -e "s|@@EMAIL@@|${EMAIL}|g" "$GFF_JOB_TEMPLATE" > "$GFF_JOB_FILE"

test_expect_success "successfully generate gff job file" '
    test -s $GFF_JOB_FILE
'

test_expect_success "submit and run deploy gff job" '
    jobs-submit -W -F $GFF_JOB_FILE >job_output 2>&1
'
job_id=$(sed -n 's/Successfully submitted job \(.*\)/\1/p' job_output)
test_expect_success "job successfully finished" '
    [[ $(jobs-status $job_id) = "FINISHED" ]]
'

test_done
