#! /bin/bash +x

# DEEP_RC_BRANCH = alpha [development server]
# DEEP_RC_PROD_BRANCH = release-x.x.x [production server]

# Ignore Pull requests
if ! [ "${TRAVIS_PULL_REQUEST}" == "false" ]; then
    echo '[Travis Build] Pull request found ... exiting...'
    exit
fi

# Ignore Non RC Branch
if [ "${TRAVIS_BRANCH}" == "${DEEP_RC_BRANCH}" -o "${TRAVIS_BRANCH}" == "${DEEP_RC_PROD_BRANCH}" ]; then
    echo '[Travis Build] RC Branch Found'
    DEPLOY_REQ_FILES=(travis-compose.yml deploy-config.json)
    for FILE in ${DEPLOY_REQ_FILES[@]}; do
        if ! [ -f ${FILE} ]; then
            echo "Error: no ${FILE} found"
            exit 1
        fi
    done
fi

mv travis-compose.yml docker-compose.yml

# configs for travis_deploy.sh
if [ "${TRAVIS_BRANCH}" == "${DEEP_RC_BRANCH}" ]; then
    echo "Generate config for Dev for branch: ${DEEP_RC_BRANCH}"
    openssl aes-256-cbc -k "$encrypted_dev_key" -in .env-dev.enc -out .env-dev -d
elif [ "${TRAVIS_BRANCH}" == "${DEEP_RC_PROD_BRANCH}" ]; then
    echo "Generate config for Prod for branch: ${DEEP_RC_PROD_BRANCH}"
    openssl aes-256-cbc -k "$encrypted_prod_key" -in .env-prod.enc -out .env-prod -d
else
    echo "No env found for current branch: ${TRAVIS_BRANCH}... exiting..."
fi
