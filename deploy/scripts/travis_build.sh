#! /bin/bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # /code/deploy/scripts/
ROOT_DIR=$(dirname "$(dirname "$BASE_DIR")") # /code/

DEEP_SERVER_REPO='https://github.com/the-deep/server.git'
DEEP_CLIENT_REPO='https://github.com/the-deep/client.git'
DEEP_REACT_STORE_REPO='https://github.com/the-deep/react-store'

SERVER_PATH=${ROOT_DIR}/server
CLIENT_PATH=${ROOT_DIR}/client
REACT_STORE_PATH=${CLIENT_PATH}/src/vendor/react-store
DEPLOY_CONFIG_PATH=$ROOT_DIR/deploy-config.json

# Ignore Pull requets
if ! [ "${TRAVIS_PULL_REQUEST}" == "false" ]; then
    echo '[Travis Build] Pull request found ... exiting...'
    exit
fi

# Ignore Non RC Branch
if ! [ \
    "${TRAVIS_BRANCH}" == "${DEEP_RC_NIGHTLY_BRANCH}" -o \
    "${TRAVIS_BRANCH}" == "${DEEP_RC_BRANCH}" -o \
    "${TRAVIS_BRANCH}" == "${DEEP_RC_PROD_BRANCH}" \
    ]; then
    echo '[Travis Build] Non RC Branch'
    exit
fi


set -e
DEEP_SERVER_DEPLOY=`jq -r '.server.deploy' ${DEPLOY_CONFIG_PATH}`
DEEP_CLIENT_DEPLOY=`jq -r '.client.deploy' ${DEPLOY_CONFIG_PATH}`

DEEP_REACT_STORE_REPO=$(jq -r ".client.reactStoreRepo // \"${DEEP_REACT_STORE_REPO}\"" ${DEPLOY_CONFIG_PATH})

DEEP_SERVER_BRANCH=`jq -r '.server.server' ${DEPLOY_CONFIG_PATH}`
DEEP_CLIENT_BRANCH=`jq -r '.client.client' ${DEPLOY_CONFIG_PATH}`
DEEP_REACT_STORE_BRANCH=`jq -r '.client.reactStore' ${DEPLOY_CONFIG_PATH}`
DEEP_RAVL_BRANCH=`jq -r '.client.ravl' ${DEPLOY_CONFIG_PATH}`
set +e

set -x
cd $ROOT_DIR

# Build server
if [ "${DEEP_SERVER_DEPLOY,,}" = "true" ]; then
    echo 'Building Server'

    git clone --branch=${DEEP_SERVER_BRANCH} ${DEEP_SERVER_REPO} ${SERVER_PATH}
    git --git-dir=${SERVER_PATH}/.git --no-pager show --pretty=fuller --quiet

    docker-compose pull redis db
    docker pull thedeep/deep-server:latest
    docker build --cache-from thedeep/deep-server:latest --tag thedeep/deep-server:latest ${SERVER_PATH}
fi

# Build client
if [ "${DEEP_CLIENT_DEPLOY,,}" = "true" ]; then
    echo 'Building Client'

    git clone --branch=${DEEP_CLIENT_BRANCH} ${DEEP_CLIENT_REPO} ${CLIENT_PATH}
    git --git-dir=${CLIENT_PATH}/.git --no-pager show --pretty=fuller --quiet

    git clone --branch=${DEEP_REACT_STORE_BRANCH} ${DEEP_REACT_STORE_REPO} ${REACT_STORE_PATH}
    git --git-dir=${REACT_STORE_PATH}/.git --no-pager show --pretty=fuller --quiet

    cp ${REACT_STORE_PATH}/stylesheets/_user-imports-sample.scss ${REACT_STORE_PATH}/stylesheets/_user-imports.scss
    docker pull thedeep/deep-client:latest
    docker build --cache-from thedeep/deep-client:latest --tag thedeep/deep-client:latest ${CLIENT_PATH}
fi
set +x
