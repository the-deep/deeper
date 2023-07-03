💻 Contributing
++++++++++++++++

How to Contribute
-----------------
Thank you for wanting to contribute to this project!
We look forward to working with you. Here is a basic set of guidelines for contributing to our project.

- Please **checkout the issues** in the deeper repository or the individual repository you want to contribute to. You can also create a new issue regarding what you want to work on. Please follow the guidelines mentioned above while creating the issue. You will need to include the link to the issue while creating a Pull Request(PR).
- **Fork** the relevant repository.

- **Make necessary changes** to the repository taking into account the coding guidelines mentioned in the individual repositories. Some general guidelines include the use of “git rebase” to organize commits and these instructions regarding commit messages:

   - Separate subjects from body with a blank line
   - Limit the subject line to 50 characters
   - Capitalize the subject line
   - Do not end the subject line with a period
   - Use the imperative mood in the subject line
- After your work is complete, **make a Pull Request** from your repository to the-deep repository. Describe what you did in as much detail as possible. Furthermore, please link to the issue in the description.

- Our development team will go through the pull request and merge them if they are satisfactory. They can also review the PR and ask for explanations/modifications.


Contributing to the Backend
-----------------------------

**Python Coding Guidelines**

- Follow [PEP 8](https://www.python.org/dev/peps/pep-0008/).

- Use 4 spaces  . . . . never tabs.

- Multiple Imports
    
**Avoid this**

.. code-block:: bash

    from .serializers import ProjectSerializer, ProjectMembershipSerializer

**Do this**

.. code-block:: bash

    from .serializers import (
        ProjectSerializer, ProjectMembershipSerializer
    )

  
**Write [unit tests](https://docs.djangoproject.com/en/1.11/topics/testing/)**

FAQ
----

- How to get a python shell [with django initialization]?

 .. code-block:: bash  

    - docker-compose up -d
    - docker-compose exec web bash
    - . /venv/bin/activate
    - python3 backend/manage.py shell

Contributing to the FrontEnd
-----------------------------

**React**

1. setState is an async function. If you need an action to be called after
   setState, it provides a second argument which accepts a callback.

2. Use immutable objects most of the time. Instead of mutating an object, use
   immutable-helpers.

3. If a re-render is expected after a value is changed, the value should be
   kept in this.state. If not, don't keep it in this.state.

4. Redux store stores global states.

5. If possible, don't instantiate objects and functions in render method. Also
   avoid writing complex logic in render method.

6. When setting a new state to component, you can only set attributes that need
   to be changed.

**Internal Libraries**

1. Use RestRequest for all REST api calls.

2. Use Form to validate form data.

3. Use RAVL to validate data from REST responses.

**DEEP React Best Practices**

1. Most likely, you will never require jquery.

2. For JSX, if there is more than one attribute, the attributes must be broken
   down in multiple lines. All these attributes should be sorted in
   alphabetical order.

3. For imports, the absolute and relative imports must be spaced with a new
   line. All the default imports must be sorted alphabetically.

4. propTypes and defaultProps for React classes must be written at the top of
   the file, only after imports. The attributes should be sorted
   alphabetically.

5. Prefer decorators for Higher-Order Components

6. Always use selectors to access data from redux store. Some additional
   calculations can be performed in selectors and the calculations are cached
   if selectors are used.

7. Always use action creators to dispatch action to redux store and always use
   action types to define an action creator.

 


