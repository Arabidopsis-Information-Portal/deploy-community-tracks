#!/bin/sh

test_description="Test Agave app BED processing"

. ./lib/sharness/sharness.sh

# grab variables from config file
. ../../../conf/config.sh

# sharness sets $HOME to the temp directory so link from $USER_HOME
ln -s "$USER_HOME/.agave" "$HOME"

BED_JOB_TEMPLATE="../templates/deploy-bed.jsonx"
BED_JOB_BN=$(basename $BED_JOB_TEMPLATE .jsonx)
BED_JOB_FILE="$BED_JOB_BN.json"

# generate job file
sed -e "s|@@DATESTAMP@@|${DATESTAMP}|g" \
    -e "s|@@APP_ID@@|${APP_ID}|g" \
    -e "s|@@ARCHIVE_PATH@@|${ARCHIVE_PATH}|g" \
    -e "s|@@EMAIL@@|${EMAIL}|g" "$BED_JOB_TEMPLATE" > "$BED_JOB_FILE"

test_expect_success "successfully generate bed job file" '
    test -s $BED_JOB_FILE
'

test_expect_success "submit and run deploy bed job" '
    jobs-submit -W -F $BED_JOB_FILE >job_output 2>&1
'

job_id=$(sed -n 's/Successfully submitted job \(.*\)/\1/p' job_output)
test_expect_success "job successfully finished" '
    [[ $(jobs-status $job_id) = "FINISHED" ]]
'

test_done
