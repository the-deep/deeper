### Deploy custom CFN Macros (Used later for copilot addons)
```bash
aws cloudformation deploy --capabilities CAPABILITY_NAMED_IAM --template-file ./aws/cfn-macros.yml --stack-name deep-custom-macros
```
### Create Client Stack
```bash
# Get hosted zone id
aws route53 list-hosted-zones-by-name --dns-name thedeep.io | jq -r '.HostedZones[0].Id' | cut -d '/' -f 3
# For staging (Replace HostedZoneId with valid value)
aws cloudformation deploy --capabilities CAPABILITY_NAMED_IAM --template-file ./aws/cfn-client.yml --stack-name deep-staging-client --tags app=deep env=staging --parameter-overrides Env=staging HostedZoneId=XXXXXXXXXXXXXXXXXXXXX
```

### SES Setup

For the email used for `EMAIL_FROM`, verify and add domain to SES.

### Dockerhub authentication
We need DOCKERHUB authentication to pull base images. To do that make sure ssm-paramter are created. Used in `copilot/buildspec.yml`
```bash
aws ssm put-parameter --name /copilot/global/DOCKERHUB_USERNAME --value <USERNAME> --type SecureString --overwrite
aws ssm put-parameter --name /copilot/global/DOCKERHUB_TOKEN --value <TOKEN> --type SecureString --overwrite
```

### Init
```bash
# Setup app with domain thedeep.io
copilot app init deep --domain thedeep.io

# Setup staging first
copilot env init --name staging --profile {profile} --default-config

# Setup each services
copilot svc init --name web
copilot svc init --name worker
copilot svc init --name export-worker
```

### [Secrets](https://aws.github.io/copilot-cli/docs/commands/secret-init/)
Load secrets (Sample: secrets-sample.yml)
```bash
copilot secret init --cli-input-yaml secrets.yml
```

### Deploy (Staging)
```bash
copilot svc deploy --name web --env staging
# Exec to the server
copilot svc exec --name web --env staging
# -- Inside container --
# Initial collectstatic & migrations
./manage.py collectstatic --no-input
./manage.py migrate  # Or migrate data manually.

# Before deploying worker, export-worker, we need to manually change the template for now.
# Make sure to not include auto-scaling addons and resource-describer on creation and then include on second deploy (i.e update)
# https://github.com/aws/copilot-cli/issues/3149
copilot svc deploy --name worker --env staging
copilot svc deploy --name export-worker --env staging
```

### Pipeline Setup
pass
