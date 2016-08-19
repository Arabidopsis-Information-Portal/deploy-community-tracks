#!/bin/sh

test_description="Agave CLI and Oauth Tests"

. ./lib/sharness/sharness.sh

# grab variables from config file
. ../../../conf/config.sh

echo ""
echo "Please make sure the Agave CLI is installed and is"
echo "available in your PATH. Also, make sure to have a current"
echo "access token from the iplantc.org tenant."
echo ""

test_expect_success "agave cli is installed" '
    command -v auth-check >/dev/null &&
    command -v apps-list >/dev/null &&
    command -v jobs-submit >/dev/null
'

# sharness sets $HOME to the temp directory so link from $USER_HOME
ln -s "$USER_HOME/.agave" "$HOME"

test_expect_success "agave cli command 'auth-check' works" '
    auth-check >auth_output
'

test_expect_success "iplantc.org tenant is selected" '
    [[ $(cat auth_output | awk "/^tenant:/ { print \$2 }") = "iplantc.org" ]]
'

test_expect_success "iplantc.org access token is current" '
    [[ $(cat auth_output | awk "/^time left:/ { print \$3 }") -gt 0 ]]
'

test_expect_success "agave cli command 'apps-list' works" '
    apps-list >apps_output
'

test_expect_success "app '$APP_ID' is installed and available to current user" '
    egrep "^$APP_ID" apps_output
'

test_done
