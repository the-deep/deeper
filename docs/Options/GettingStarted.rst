
💡 Getting Started
+++++++++++++++++++

General
----------
What's the stack like? We're glad you asked. DEEP's server is powered by
Django/Postgresql and we use React for most front end tasks. The whole kit and
caboodle is wrapped up in Docker and you can easily deploy DEEP on your local
machine to begin developing. 

The information below will help you get started on building DEEP locally.

Dependencies
--------------

Most of the dependencies for the deeper are provided in Dockerfile,
package.json & pyproject.yml which are installed automatically using
docker.

Clone Deeper Repo
-------------------

git clone https://github.com/the-deep/deeper.git deep-project-root

**Goto Deeper project root**

.. code-block:: bash  

 cd deep-project-root

**Clone client and server**

git clone https://github.com/the-deep/server.git server

git clone https://github.com/the-deep/client.git client

git clone https://github.com/the-deep/deepl-deep-integration.git deepl-service

**Setup client**

.. code-block:: bash     

 cd client

**Building**

Install `docker` and `docker-compose v3`..
And run the following commands every time dependencies are updated.

.. code-block:: bash  

 cd deep-project-root
 # Copy ./env-sample as .env
 cp .env-sample .env
 docker-compose pull
 docker-compose build

**Useful commands for running Docker**

- Starting docker containers

.. code-block:: bash  
 
  docker-compose up               # non-detached mode, shows logs, ctrl+c to exit
  docker-compose up -d            # detached mode, runs in background
 
- Running django migrations

.. code-block:: bash  

  docker-compose exec web ./manage.py migrate
   

- Viewing logs (for detached mode)

.. code-block:: bash  

  docker-compose logs -f          # view logs -f is for flow
  docker-compose logs -f web      # view logs for web container
  docker-compose logs -f worker      # view logs for worker container
  
- Running commands

.. code-block:: bash  

  docker-compose exec web <command>    # Run commands inside web container
  docker-compose exec web bash         # Get into web container's bash
   
[Note: `web` is the container name (view `docker-compose.yml`)]


**Useful Plugins for Debugging React**

- [React Developer Tools](https://chrome.google.com/webstore/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi?hl=en)
- [Redux DevTools](https://chrome.google.com/webstore/detail/redux-devtools/lmhkpmbekcpmknklioeibfkpmmfibljd?hl=en)

**Adding dependencies [web]**

- Get into web container bash

.. code-block:: bash  

 docker-compose exec web bash
  

- Adding Server Dependencies [Python]
   
  In server directory

  Add package in pyproject.yml file

.. code-block:: bash  

  Run poetry lock --no-update

  In deeper directory

.. code-block:: bash  

 docker compose build  

## Adding dependencies [Client]

- Get into client container bash

.. code-block:: bash  

 docker-compose exec client bash
  
- Adding Client Dependencies [JS]

.. code-block:: bash  

 cd code/
 yarn add <dependency>       # Installs dependency and updates package.json and yarn.lock

**Running tests locally**

- Python/Django tests

.. code-block:: bash

 docker-compose exec web bash
 **Inside web container**
    
.. code-block:: bash

 docker-compose exec web pytest  # Run all test with fresh database
 docker-compose exec web pytest --reuse-db --last-failed -vv  # Run last failed test but reuse existing db
 docker-compose exec web pytest apps/user/tests/test_schemas.py::TestUserSchema::test_user_last_active  # Run specific tests

- JS/React test

.. code-block:: bash

 docker-compose exec client bash
 
 **Inside client container**

.. code-block:: bash

 cd /code/
 yarn test                   # Provides different usages
 yarn test a                 # Overall JS/React test
 yarn test o                 # Test only changed files
 yarn test --coverage        # Also generate coverage
 

