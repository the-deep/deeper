#! /bin/bash

# NOTE: Run after travis_export_config

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # /code/deploy/scripts/
ROOT_DIR=$(dirname "$(dirname "$BASE_DIR")") # /code/

DEPLOY_CONFIG_PATH=$ROOT_DIR/deploy-config.json

DEEP_SERVER_DEPLOY=`jq -r '.client.deploy' ${DEPLOY_CONFIG_PATH}`
DEEP_CLIENT_DEPLOY=`jq -r '.server.deploy' ${DEPLOY_CONFIG_PATH}`

if ! [ "${TRAVIS_PULL_REQUEST}" == "false" ]; then
    echo '[Travis Build] Pull request found ... exiting...'
    exit
fi

# Ignore Non RC Branch
if ! [ "${TRAVIS_BRANCH}" == "${DEEP_RC_BRANCH}" -o "${TRAVIS_BRANCH}" == "${DEEP_RC_PROD_BRANCH}" ]; then
    echo '[Travis Build] Non RC Branch'
    exit
fi

set -x
if [ "${DEEP_SERVER_DEPLOY,,}" = "true" ]; then
    docker-compose up -d server
    docker-compose exec server \
        bash -c 'export CI=false; /code/scripts/wait-for-it.sh db:5432 && /code/scripts/run_tests.sh'
fi

if [ "${DEEP_CLIENT_DEPLOY,,}" = "true" ]; then
    python -c "import fcntl; fcntl.fcntl(1, fcntl.F_SETFL, 0)"
    docker run -t thedeep/deep-client:latest bash -c 'CI=true yarn test'
fi
set +x
