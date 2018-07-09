# Getting Started

> Author: the one and the only [thenav56](https://github.com/thenav56)

## General
What's the stack like? We're glad you asked. DEEP's server is powered by Django/Postgresql and we use React for most front end tasks. The whole kit and caboodle is wrapped up in Docker and you can easily deploy DEEP on your local machine to begin developing. 

The information below will help you get started on building DEEP locally.

## Dependencies
Most of the dependencies for the deeper are provided in Dockerfile, package.json and requirements.txt which are installed automatically using docker.

But two dependency has to be cloned manually: [react-store](http://github.com/toggle-corp/react-store/) and [ravl](http://github.com/toggle-corp/ravl/)

```bash
# Clone Deeper Repo
git clone https://github.com/the-deep/deeper.git deep-project-root

# Goto Deeper project root
cd deep-project-root

# Clone client and server
git clone https://github.com/the-deep/server.git
git clone https://github.com/the-deep/client.git

# Setup client
cd client
yarn vendor:clone
cp client/src/vendor/react-store/stylesheets/_user-imports-sample.scss client/src/vendor/react-store/stylesheets/_user-imports.scss
```


## Building

Install `docker` and `docker-compose v3`...

And run the following commands everytime dependencies are updated.
```bash
cd deep-project-root
docker-compose pull
docker-compose build
```

## Useful commands for running Docker

- Starting docker containers
    ```bash
    docker-compose up               # non-detached mode, shows logs, ctrl+c to exit
    docker-compose up -d            # detached mode, runs in background
    ```
- Viewing logs (for detached mode)
    ```bash
    docker-compose logs -f          # view logs -f is for flow
    docker-compose logs -f server      # view logs for server container
    ```

- Running commands
    ```bash
    docker-compose exec server <command>    # Run commands inside server container
    docker-compose exec server bash         # Get into server container's bash
    ```

[Note: `server` is the container name (view `docker-compose.yml`)]

## Useful Plugins for Debugging React

- [React Developer Tools](https://chrome.google.com/webstore/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi?hl=en)
- [Redux DevTools](https://chrome.google.com/webstore/detail/redux-devtools/lmhkpmbekcpmknklioeibfkpmmfibljd?hl=en)

## Adding dependencies [Server]

- Get into server container bash

    ```bash
    docker-compose exec server bash
    ```

- Adding Server Dependencies [Python]

    - Avoid `pip freeze > requirements.txt`

    - Temporary dependency install [Dependency might not be in next `docker-compose up`]
    ```bash
    cd /code/
    . /venv/bin/activate                     # Activate virtualenv
    pip3 install <dependency>                # Install dependency
    pip3 freeze | grep <dependency>          # Get depedency version
    vim requirements.txt                     # Update python requirements [This will exist in next up]
    ```
    - Permanently install a dependnacy
        - `docker-compose build` after `requirements.txt` is updated

## Adding dependencies [Client]

- Get into client container bash

    ```bash
    docker-compose exec client bash
    ```

- Adding Client Dependencies [JS]

    ```bash
    cd code/
    yarn add <dependency>       # Installs dependency and updates package.json and yarn.lock
    ```

## Running tests locally

- Python/Django tests
    ```bash
    docker-compose exec server bash

    # Inside server container
    . /venv/bin/activate
    cd /code/
    python3 manage.py test                      # Dango tests
    python3 manage.py test <app.module>         # Specific app module test
    ```

- JS/React test
    ```bash
    docker-compose exec client bash

    # Inside client container
    cd /code/
    yarn test                   # Provides different usages
    yarn test a                 # Overall JS/React test
    yarn test o                 # Test only changed files
    yarn test --coverage        # Also generate coverage
    ```
