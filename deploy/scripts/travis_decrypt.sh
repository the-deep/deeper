#! /bin/bash +x

# DEEP_RC_NIGHTLY_BRANCH = nightly [nightly server]
# DEEP_RC_BRANCH = alpha [staging server]
# DEEP_RC_PROD_BRANCH = release-x.x.x [production server]

# Ignore Pull requests
if ! [ "${TRAVIS_PULL_REQUEST}" == "false" ]; then
    echo '[Travis Build] Pull request found ... exiting...'
    exit
fi

# Check for RC Branch
if [ \
    "${TRAVIS_BRANCH}" == "${DEEP_RC_NIGHTLY_BRANCH}" -o \
    "${TRAVIS_BRANCH}" == "${DEEP_RC_BRANCH}" -o \
    "${TRAVIS_BRANCH}" == "${DEEP_RC_PROD_BRANCH}" \
    ]; then
    echo '[Travis Build] RC Branch Found'
    DEPLOY_REQ_FILES=(deploy-config.json)
    for FILE in ${DEPLOY_REQ_FILES[@]}; do
        if ! [ -f ${FILE} ]; then
            echo "Error: no ${FILE} found"
            exit 1
        fi
    done
fi

# configs for travis_deploy.sh
if [ "${TRAVIS_BRANCH}" == "${DEEP_RC_NIGHTLY_BRANCH}" ]; then
    echo "Generate config for Nightly for branch: ${DEEP_RC_NIGHTLY_BRANCH}"
    aws ssm get-parameter --with-decryption --name $NIGHTLY_SSM_NAME | jq -r '.Parameter.Value' > .env-nightly
elif [ "${TRAVIS_BRANCH}" == "${DEEP_RC_BRANCH}" ]; then
    echo "Generate config for Alpha for branch: ${DEEP_RC_BRANCH}"
    aws ssm get-parameter --with-decryption --name $DEV_SSM_NAME | jq -r '.Parameter.Value' > .env-dev
elif [ "${TRAVIS_BRANCH}" == "${DEEP_RC_PROD_BRANCH}" ]; then
    echo "Generate config for Prod for branch: ${DEEP_RC_PROD_BRANCH}"
    aws ssm get-parameter --with-decryption --name $PROD_SSM_NAME | jq -r '.Parameter.Value' > .env-prod
else
    echo "No env found for current branch: ${TRAVIS_BRANCH}... exiting..."
fi
