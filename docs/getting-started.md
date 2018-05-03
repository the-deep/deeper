# Getting Started

> Author: the one and the only [thenav56](https://github.com/thenav56)

## General
What's the stack like? We're glad you asked. DEEP's backend is powered by Django/Postres and we use React for most front end tasks. The whole kit and caboodle is wrapped up in Docker and you can easily deploy DEEP on your local machine to begin developing. 

The information below will help you get started on building DEEP locally.

## Dependencies
Most of the dependencies for the deeper are provided in Dockerfile, package.json and requirements.txt which are installed automatically using docker.

But two dependency has to be cloned manually: [react-store](http://github.com/toggle-corp/react-store/) and [ravl](http://github.com/toggle-corp/ravl/)

```bash
# Goto Deeper project root
cd deep-project-root

# Clone react-store [ react-store setup ]
git clone https://github.com/toggle-corp/react-store.git frontend/src/vendor/react-store
cp frontend/src/vendor/react-store/stylesheets/_user-imports-sample.scss frontend/src/vendor/react-store/stylesheets/_user-imports.scss

# Clone ravl
git clone https://github.com/toggle-corp/ravl.git frontend/src/vendor/ravl
```


## Building

Install `docker` and `docker-compose v3`...

And run the following commands everytime dependencies are updated.
```bash
cd deep-project-root
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
    docker-compose logs -f web      # view logs for web container
    ```

- Running commands
    ```bash
    docker-compose exec web <command>    # Run commands inside web container
    docker-compose exec web bash         # Get into web container's bash
    ```

[Note: `web` is the container name (view `docker-compose.yml`)]

## Useful Plugins for Debugging React

- [React Developer Tools](https://chrome.google.com/webstore/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi?hl=en)
- [Redux DevTools](https://chrome.google.com/webstore/detail/redux-devtools/lmhkpmbekcpmknklioeibfkpmmfibljd?hl=en)

## Adding dependencies

- Get into web container bash

    ```bash
    docker-compose exec web bash
    ```

- Adding Frontend Dependencies [JS]

    ```bash
    cd frontend/
    yarn add <dependency>       # Installs dependency and updates package.json and yarn.lock
    ```

- Adding Backend Dependencies [Python]

    - Avoid `pip freeze > requirements.txt`

    - Temporary dependency install [Dependency might not be in next `docker-compose up`]
    ```bash
    cd backend/
    . /venv/bin/activate                     # Activate virtualenv
    pip3 install <dependency>                # Install dependency
    pip3 freeze | grep <dependency>          # Get depedency version
    vim requirements.txt                     # Update python requirements [This will exist in next up]
    ```
    - Permanently install a dependnacy
        - `docker-compose build` after `requirements.txt` is updated

## Running tests locally

- Initial commands
    ```bash
    docker-compose exec web bash

    # Inside container
    . /venv/bin/activate
    ```

- Run overall project tests
    ```bash
    # Inside container
    tox                         # Overall project tests
    ```

- Python/Django tests
    ```bash
    # Inside container
    cd /code/backend/
    python3 manage.py test                      # Dango tests
    python3 manage.py test <app.module>         # Specific app module test
    ```

- JS/React test
    ```bash
    # Inside container
    cd /code/frontend/
    yarn test                   # Provides different usages
    yarn test a                 # Overall JS/React test
    yarn test o                 # Test only changed files
    yarn test --coverage        # Also generate coverage
    ```

## Loading dummy data

Dummy data is available in the form of csv files and can be loaded/updated with the `load_dummy_data`
management command.

> Load Dummy Data.

Start containers
```bash
cd project-root-folder

# Start Docker containers... you can start without -d if you just open another terminal at project-root-folder
docker-compose up -d

# ssh to web container
docker-compose exec web bash
```

From outside container
```bash
docker-compose exec web bash -c "./scripts/load_dummy_data.sh"
```

From inside container [Optional]
```
# cd to django root folder
cd backend

# activate python virtualenv
. /venv/bin/activate

# load dummy data
python3 manage.py load_dummy_data

# exit container
exit
```

> Add Dummy Data.

- csv filename should be same as the Model name  [`backend/*/models.py`].
- The csv file of the required model should be stored in its respective django app. [`backend/*/dummy_data/`].
- The `id` column maintains relatiosn between models and their instance in the database.
- Look into the already added dummy_data for reference. [`backend/geo/dummy_data/Region.csv`]
    - Here the model is region, its class name is `Region` and its in the app `geo`
