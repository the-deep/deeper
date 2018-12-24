#! /bin/bash

# deeper/deploy/scripts/
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# deeper/
ROOT_DIR=$(dirname "$(dirname "$BASE_DIR")")

SAMPLE_DIR=$ROOT_DIR/deploy/eb-sample
CURRENT_DIR=$(pwd)

# Passed params
ENV_FILE=${1}

echo "::::: Gettings ENV Variables :::::"

if [ -f "$ENV_FILE" ]; then
    echo "  >> Gettings ENV from file $ENV_FILE "
    source $ENV_FILE
    export $(grep -v '^#' $ENV_FILE | cut -d= -f1)
else
    echo "  >> ENV FILE ${ENV_FILE} NOT FOUND ... Exiting....."
    exit 1
fi

# Additional env
export DEPLOYMENT_ENV_NAME=$DEPLOYMENT_ENV_NAME_WORKER
export TYPE=worker
# export DJANGO_ALLOWED_HOST_WEBSOCKET=${DJANGO_ALLOWED_HOST_CERN}

set -e;
envsubst < $SAMPLE_DIR/.ebextensions/environmentvariables.config-sample | \
    jq -r \
        '.option_settings[]|.option_name as $option_name|.value as $value| [$option_name, $value]|join("=")' \
        > $ROOT_DIR/.env-cern
echo 'DEEP_ENVIRONMENT=beta' >> $ROOT_DIR/.env-cern
echo "DEPLOYMENT_REGION=${DEPLOYMENT_REGION}" >> $ROOT_DIR/.env-cern
echo 'IN_CERN=True' >> $ROOT_DIR/.env-cern

# FIXME: fix this later
sed "s/DJANGO_ALLOWED_HOST=/#DJANGO_ALLOWED_HOST=/g" -i $ROOT_DIR/.env-cern
sed "s/DJANGO_ALLOWED_HOST_WEBSOCKET=/#DJANGO_ALLOWED_HOST_WEBSOCKET=/g" -i $ROOT_DIR/.env-cern
sed "s/DJANGO_ALLOWED_HOST_API=/#DJANGO_ALLOWED_HOST_API=/g" -i $ROOT_DIR/.env-cern

echo "  >> Exported ENV to file $ROOT_DIR/.env-cern "
set +e;
