# DEEP (Extended Release)

DEEP is an open source, community driven web application to intelligently collect, tag, analyze and export secondary data. This repository contains code for DEEP 2.0, a large full-stack rewrite of DEEP 1.0.

DEEP's brain is powered by DEEPL, an suite of tools to provide NLP recommendations to the platform. Its code can be found [here](https://github.com/eoglethorpe/deepl).

If you are interested in contributing, please checkout the information below and post an issue if you have any questions or would like to chat.

## References

- [Creating an issue related to deep](docs/create-issue.md)
- [Contributing - Getting Started](docs/getting-started.md)
- [Contributing - Frontend Details](docs/contributing_frontend.md)
- [Contributing - Backend Details](docs/contributing_backend.md)
- [DEEP Git For n00bz](docs/git.md)
- [REST API](docs/api-rest.md)
- [Websocket API](docs/api-websocket.md)
- [Testing... Frontend](docs/testing_frontend.md)
- [Testing... Backend](docs/testing_backend.md)

## Staging Servers

- [Development website](https://alpha.thedeep.io)
- [API](https://api.alpha.thedeep.io)

## Copilot Deployment

### Deploy custom CFN Macros (Used later for copilot addons)
```
aws cloudformation deploy --capabilities CAPABILITY_NAMED_IAM --template-file ./aws/cfn-macros.yml --stack-name deep-custom-macros
```
### SES Setup

For the email used for `EMAIL_FROM`, verify and add domain to SES.

### Init
```
copilot app init deep --domain thedeep.io
copilot env init --name {stage} --profile {profile} --default-config
copilot svc init --name web
```

### [Secrets](https://aws.github.io/copilot-cli/docs/commands/secret-init/)
Load secrets (Sample: secrets-sample.yml)
```
copilot secret init --cli-input-yaml secrets.yml
```

### Deploy
Load secrets (Sample: secrets-sample.yml)
```
copilot svc deploy --name web --env {stage}
```
