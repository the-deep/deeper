#! /bin/bash

ENV_FILE=$1
ONLY_DEPLOY=$2 # client/server
DJANGO_ONLY_DEPLOY=$3 # web/worker

echo "::::: Gettings ENV Variables :::::"
    if [ -f "$ENV_FILE" ]; then
        echo "  >> Gettings ENV from file $ENV_FILE "
        source $ENV_FILE
        export $(grep -v '^#' $ENV_FILE | cut -d= -f1)
    else
        echo "  >> ENV FILE NOT FOUND ... Exiting....."
        exit 1
    fi

if [ '${TRAVIS}' == 'true' ]; then
    echo ":::::::: In Travis ::::::::"
    echo "::::: Configuring AWS :::::"
    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
    aws configure set default.region $DEPLOYMENT_REGION
    aws configure set metadata_service_timeout 1200
    aws configure set metadata_service_num_attempts 3
fi

# /deeper/deploy/
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# /deeper/
ROOT_DIR=$(dirname "$BASE_DIR")
# eb sample config files path
EB_SAMPLE_DIR=$ROOT_DIR/deploy/eb-sample

if [ "${ONLY_DEPLOY}" == "" ] || [ "${ONLY_DEPLOY}" == "server" ] ; then
printf "\n\n::::: DOCKER TASK :::::\n"

    if ! [ -z ${TRAVIS_BUILD_ID+x} ]; then
        DOCKER_BUILD_ID=$TRAVIS_BUILD_ID
    fi
    if [ -z ${DOCKER_BUILD_ID+x} ]; then
        echo "ERROR::: DOCKER_BUILD_ID not set"
        exit 1
    fi
    if ! [ -z ${BUILD_ID_POSTFIX+x} ]; then
        # Add postfix to build id (to seperate dev/prod images)
        DOCKER_BUILD_ID=$DOCKER_BUILD_ID-$BUILD_ID_POSTFIX
    fi

    # cd to Project Root Directory
    cd $ROOT_DIR
    # Login to docker hub and Build Image
    set -e;
    echo "  >> Logging In to DockerHub "
        echo "$LOGIN_DOCKER_PASSWORD" | docker login -u "$LOGIN_DOCKER_USERNAME" --password-stdin
    echo "  >> Tagging Image ($DOCKER_USERNAME/$DOCKER_REPOSITORY:$DOCKER_BUILD_ID)"
        docker tag thedeep/deep-server:latest $DOCKER_USERNAME/$DOCKER_REPOSITORY:$DOCKER_BUILD_ID
    echo "  >> Pushing Image ($DOCKER_USERNAME/$DOCKER_REPOSITORY:$DOCKER_BUILD_ID)"
        docker push $DOCKER_USERNAME/$DOCKER_REPOSITORY:$DOCKER_BUILD_ID
    set +e;

    printf "\n\n:::::::: Generating Configs From ENVIRONMENT VARIABLES ::::::::"
    ENV_TYPE=(web worker)

    for TYPE in ${ENV_TYPE[@]}; do
        export TYPE
        if [ "${DJANGO_ONLY_DEPLOY}" == "" ] || [ "${DJANGO_ONLY_DEPLOY}" == "${TYPE}" ] ; then
            printf "\n\n::::::::::::::::::::: Config for EB [$TYPE] :::::::::::::::::::::\n"
            TYPE_DIR=$ROOT_DIR/deploy/eb/$TYPE
            # rm -rf $TYPE_DIR
            mkdir -p $TYPE_DIR/.ebextensions
            cd $TYPE_DIR

            echo "  >> Creating .elasticbeanstalk/config.yml file :::::"
            if [ ${TYPE} == 'web' ]; then
                echo "1" | eb init $DEPLOYMENT_APP_NAME --region $DEPLOYMENT_REGION && eb use $DEPLOYMENT_ENV_NAME_WEB
                export DEPLOYMENT_ENV_NAME=$DEPLOYMENT_ENV_NAME_WEB
            else
                echo "1" | eb init $DEPLOYMENT_APP_NAME --region $DEPLOYMENT_REGION && eb use $DEPLOYMENT_ENV_NAME_WORKER
                export DEPLOYMENT_ENV_NAME=$DEPLOYMENT_ENV_NAME_WORKER
            fi

            echo "::::::: Creating additional configs :::::"

                if [ ${TYPE} == 'web' ]; then
                    echo "      >> Creating remote_log for ec2 instance"
                    cp $EB_SAMPLE_DIR/.ebextensions/remote_log.config-sample ./.ebextensions/remote_log.config
                    sed "s/host:.*/host: $PAPERTRAIL_HOST/" -i ./.ebextensions/remote_log.config
                    sed "s/port:.*/port: $PAPERTRAIL_PORT/" -i ./.ebextensions/remote_log.config
                fi

                echo "      >> Creating environmentvariables [validation environmentvariables]"
                set -e;
                    envsubst < $EB_SAMPLE_DIR/.ebextensions/environmentvariables.config-sample | \
                        jq -r '.' > ./.ebextensions/environmentvariables.config # validate json and export
                set +e;

                if [ ${TYPE} == 'web' ]; then
                    echo "      >> Creating nginx.conf"
                        cp $EB_SAMPLE_DIR/.ebextensions/01_nginx.config ./.ebextensions/01_nginx.config
                        cp $EB_SAMPLE_DIR/.ebextensions/nginx.conf-sample ./.ebextensions/nginx.conf
                        sed "s/server_name #ALLOWED_HOST.*/server_name $DJANGO_ALLOWED_HOST_API;/" -i ./.ebextensions/nginx.conf
                        sed "s/proxy_pass #S3_BUCKET_NAME_STATIC.*/proxy_pass https:\/\/$DJANGO_AWS_STORAGE_BUCKET_NAME_STATIC.s3.amazonaws.com\/static;/" -i ./.ebextensions/nginx.conf
                        sed "s/proxy_pass #S3_BUCKET_NAME_MEDIA.*/proxy_pass https:\/\/$DJANGO_AWS_STORAGE_BUCKET_NAME_MEDIA.s3.amazonaws.com\/media;/" -i ./.ebextensions/nginx.conf
                fi

                echo "      >> Creating .mydockercfg "
                    DOCKER_AUTH_TOKEN=($(jq -r '.auths["https://index.docker.io/v1/"].auth' ~/.docker/config.json))
                    cat $EB_SAMPLE_DIR/.mydockercfg-sample \
                        | sed 's\DOCKER_AUTH\'$DOCKER_AUTH_TOKEN'\' \
                        | sed 's\DOCKER_EMAIL\'$LOGIN_DOCKER_EMAIL'\' \
                        > ./.mydockercfg

                echo "      >> Uploading .mydockercfg "
                aws s3 cp ./.mydockercfg s3://$DEPLOYMENT_BUCKET/$DEPLOYMENT_DOCKER_AUTH_KEY

                if [ ${TYPE} == 'web' ]; then
                    echo "      >> Creating Dockerrun.aws.json "
                        cat $EB_SAMPLE_DIR/Dockerrun.aws.json-sample \
                            | sed 's\DEPLOYMENT_BUCKET\'$DEPLOYMENT_BUCKET'\' \
                            | sed 's\DOCKER_AUTH_FILE\'.mydockercfg'\' \
                            | sed 's\DOCKER_IMAGE\'$DOCKER_USERNAME/$DOCKER_REPOSITORY'\' \
                            | sed 's\DOCKER_TAG\'$DOCKER_BUILD_ID'\' \
                            > ./Dockerrun.aws.json
                else
                    echo "      >> Creating Dockerrun.aws.json "
                        cat $EB_SAMPLE_DIR/DockerrunMulti.aws.json-sample \
                            | sed 's\DEPLOYMENT_BUCKET\'$DEPLOYMENT_BUCKET'\' \
                            | sed 's\DOCKER_AUTH_FILE\'.mydockercfg'\' \
                            | sed 's\DOCKER_IMAGE\'$DOCKER_USERNAME/$DOCKER_REPOSITORY'\g' \
                            | sed 's\DOCKER_TAG\'$DOCKER_BUILD_ID'\g' \
                            > ./Dockerrun.aws.json
                fi


            echo "  >> Deploying to eb [$TYPE]"
                if [ "${TRAVIS}" == "true" ]; then
                    eb deploy --nohang
                else
                    eb deploy
                fi
            fi
    done
fi

if [ "${ONLY_DEPLOY}" == "" ] || [ "${ONLY_DEPLOY}" == "client" ] ; then
printf "\n\n::::::::: Deploying React to S3 [Client] :::::::::::\n"
    CLIENT_DIR=${ROOT_DIR}/client

    echo "
    REACT_APP_API_HTTPS=${DEEP_HTTPS}
    REACT_APP_API_END=${DJANGO_ALLOWED_HOST_API}
    REACT_APP_ADMIN_END=${DJANGO_ALLOWED_HOST_API}
    REACT_APP_HID_CLIENT_ID=${HID_CLIENT_ID}
    REACT_APP_HID_CLIENT_REDIRECT_URL=${HID_CLIENT_REDIRECT_URL}
    REACT_APP_HID_AUTH_URI=${HID_AUTH_URI}
    REACT_APP_MAPBOX_ACCESS_TOKEN=${MAPBOX_ACCESS_TOKEN}
    REACT_APP_MAPBOX_STYLE=${MAPBOX_STYLE}
    " > ${CLIENT_DIR}/.env

    set -e;
    echo "::::::  >> Generating New Reacts Builds [Locally]"
    python -c "import fcntl; fcntl.fcntl(1, fcntl.F_SETFL, 0)"
    docker run -t -v ${CLIENT_DIR}/build:/code/build --env-file=${CLIENT_DIR}/.env \
        thedeep/deep-client:latest \
        bash -c 'yarn install && CI=false yarn build'
    set +e;

    rm ${CLIENT_DIR}/.env

    echo "::::::  >> Remove Previous Builds Files [js, css] From S3 Bucket [$DJANGO_AWS_STORAGE_BUCKET_NAME_STATIC]"
    aws s3 rm s3://$DJANGO_AWS_STORAGE_BUCKET_NAME_STATIC/static/js --recursive
    aws s3 rm s3://$DJANGO_AWS_STORAGE_BUCKET_NAME_STATIC/static/css --recursive
    echo "::::::  >> Uploading New Builds Files To S3 Bucket [$DJANGO_AWS_STORAGE_BUCKET_NAME_STATIC]"
    aws s3 sync ${CLIENT_DIR}/build/ s3://$DJANGO_AWS_STORAGE_BUCKET_NAME_STATIC
    echo "::::::  >> Settings Configs for Bucket [$DJANGO_AWS_STORAGE_BUCKET_NAME_STATIC]"
    # disable index.html cache
    aws s3 cp ${CLIENT_DIR}/build/index.html s3://$DJANGO_AWS_STORAGE_BUCKET_NAME_STATIC/index.html \
        --metadata-directive REPLACE --cache-control max-age=0,no-cache,no-store,must-revalidate --content-type text/html --acl public-read
    # disable service-worker.js cache
    aws s3 cp ${CLIENT_DIR}/build/service-worker.js s3://$DJANGO_AWS_STORAGE_BUCKET_NAME_STATIC/service-worker.js \
        --metadata-directive REPLACE --cache-control max-age=0,no-cache,no-store,must-revalidate --content-type application/javascript --acl public-read
    # S3 website settings config
    aws s3 website s3://$DJANGO_AWS_STORAGE_BUCKET_NAME_STATIC --index-document index.html --error-document index.html

    # Clear cloudflare cache [only for deeper.togglecorp.com ]
    echo ":::::: Clear cloudflare cache"
    # Get the zones
    CLOUDFLARE_ZONES=($(curl -X GET "https://api.cloudflare.com/client/v4/zones" \
         -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
         -H "X-Auth-Key: ${CLOUDFLARE_KEY}" \
         -H "Content-Type: application/json" | jq -r '.result[].id'))

    for CLOUDFLARE_ZONE in ${CLOUDFLARE_ZONES[@]}; do
        # Clear the cache
        curl -X DELETE "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE}/purge_cache" \
             -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
             -H "X-Auth-Key: ${CLOUDFLARE_KEY}" \
             -H "Content-Type: application/json" \
             --data '{"purge_everything":true}'
    done
fi
