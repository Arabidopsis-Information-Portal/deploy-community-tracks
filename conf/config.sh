# this get sourced into test files

USERNAME=eriksf
EMAIL=eferlanti@tacc.utexas.edu
VERSION=$(cat ../../../VERSION)
DATESTAMP=$(date +%m%d%Y-%k%M)
BEARER_TOKEN=19aaedef4af51ca537e9a795364d86c
APP_SRC=deploy-community-tracks
APP_NAME=eriksf-araport-deploy-community-tracks
APP_ID=eriksf-araport-deploy-community-tracks-${VERSION}
ARCHIVE_PATH=araport/community-tracks/staging
DEPLOYMENT_BASE=eriksf/applications
DEPLOYMENT_PATH=${DEPLOYMENT_BASE}/${APP_SRC}
