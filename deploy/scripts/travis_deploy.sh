#! /bin/bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # /code/deploy/scripts/
ROOT_DIR=$(dirname "$(dirname "$BASE_DIR")") # /code/

CLIENT_PATH=${ROOT_DIR}/client
REACT_STORE_PATH=${CLIENT_PATH}/src/vendor/react-store

DEPLOY_CONFIG_PATH=$ROOT_DIR/deploy-config.json

echo "Branch=${TRAVIS_BRANCH}, Pull request=${TRAVIS_PULL_REQUEST}"
echo "************************************************************";

# Don't deploy pull requests
if ! [ "${TRAVIS_PULL_REQUEST}" == "false" ]; then
    echo '[Travis Build] Pull request found ... exiting...'
    exit
fi

set -e
DEEP_SERVER_DEPLOY=`jq -r '.server.deploy' ${DEPLOY_CONFIG_PATH}`
DEEP_CLIENT_DEPLOY=`jq -r '.client.deploy' ${DEPLOY_CONFIG_PATH}`
set +e

set -ex
# Check if the branch is release candidate, use .env-dev config
if [ "${TRAVIS_BRANCH}" == "${DEEP_RC_NIGHTLY_BRANCH}" ]; then
    echo "Deploying using Release Candidate [Nightly]: ${DEEP_RC_NIGHTLY_BRANCH}";
    export DEEP_ENVIRONMENT='nightly'
    DEEPER_DEPLOY_ENV_FILE=${ROOT_DIR}/.env-nightly
elif [ "${TRAVIS_BRANCH}" == "${DEEP_RC_BRANCH}" ]; then
    echo "Deploying using Release Candidate [Alpha]: ${DEEP_RC_BRANCH}";
    export DEEP_ENVIRONMENT='alpha'
    DEEPER_DEPLOY_ENV_FILE=${ROOT_DIR}/.env-dev
# if it is for production, use .env-prod config
elif [ "${TRAVIS_BRANCH}" == "${DEEP_RC_PROD_BRANCH}" ]; then
    echo "Deploying using Production [Beta] Release Candidate ${DEEP_RC_PROD_BRANCH}";
    export DEEP_ENVIRONMENT='beta'
    DEEPER_DEPLOY_ENV_FILE=${ROOT_DIR}/.env-prod
fi

# exit if no config is set
if [ -z ${DEEPER_DEPLOY_ENV_FILE+x} ]; then
    echo "No config found for branch: ${TRAVIS_BRANCH}"
    exit
fi

if [ "${DEEP_SERVER_DEPLOY,,}" = "true" ]; then
    printf "\n\n:::::::::::::::::: Deploying Server ::::::::::::::::::::\n"
    ./deploy/deploy_deeper.sh $DEEPER_DEPLOY_ENV_FILE server
fi
if [ "${DEEP_CLIENT_DEPLOY,,}" = "true" ]; then
    printf "\n\n:::::::::::::::::: Deploying Client ::::::::::::::::::::\n"
    export DEEP_CLIENT_COMMIT_SHA=$(git --git-dir=${CLIENT_PATH}/.git rev-parse HEAD)
    export DEEP_REACT_STORE_COMMIT_SHA=$(git --git-dir=${REACT_STORE_PATH}/.git rev-parse HEAD)
    ./deploy/deploy_deeper.sh $DEEPER_DEPLOY_ENV_FILE client
fi

set +ex
