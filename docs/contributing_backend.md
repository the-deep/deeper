# Contributing to the Backend

## Project Structure

    . backend
    ├── analysis_framework
    ├── deep
    │   ├── test_files
    ├── entry
    ├── geo
    ├── htmlcov
    ├── jwt_auth
    ├── lead
    ├── project
    ├── redis_store
    ├── user
    ├── user_group
    ├── user_resource
    ├── utils
    │   ├── extractor
    │   ├── hid
    │   └── websocket
    └── websocket


## Python Coding Guidelines

- Follow [PEP 8](https://www.python.org/dev/peps/pep-0008/).

- Use 4 spaces  . . . . never tabs. Enough said.

- Multiple Imports
    ```python
    # Avoid this
    from .serializers import ProjectSerializer, ProjectMembershipSerializer

    # Do this
    from .serializers import (
        ProjectSerializer, ProjectMembershipSerializer
    )
    ```
- Write [unit tests](https://docs.djangoproject.com/en/1.11/topics/testing/), much like your mother taught you.

## FAQ

- How to get a python shell [with django initialization]?
    ```
    docker-compose up -d
    docker-compose exec web bash
    . /venv/bin/activate
    python3 backend/manage.py shell
    ```
