📄 Documentation
++++++++++++++++

Introduction
------------

DEEP's documentation is built on top of `Sphinx <https://www.sphinx-doc.org/en/master/>`_ and uses a theme provided by `Read the Docs <https://about.readthedocs.com/?ref=readthedocs.org>`_. We accept contributions to the documentation of the DEEP project too.

Contributions to Documentation
------------------------------

Contributions to DEEP's documentation must adhere to the contribution guidelines, just like any other code contribution.
DEEP's documentation is generated as a static page using Sphinx. During deployment, the docs are generated using a pre-deployment pipeline in a similar manner. For local creation of docs, refer the notes below.

**Steps to generate DEEP docs locally**

#. Navigate to the documentation folder:

    .. code-block:: bash  

        cd docs/

#. Install sphinx and supporting packages:

    .. code-block:: bash  

        pip install -r requirements.txt

#. Generate static documentation locally:

    .. code-block:: bash

        make html

#. View the generated docs by opening the index file in your browser, at the following path: :code:`<path-to-project>/docs/_build/html/index.html`

Useful References
-----------------

*   `sphinx-autobuild <https://pypi.org/project/sphinx-autobuild/>`_ is a tool that auto-builds the documentation everytime a change is detected in the ``docs/`` folder
*   `rst Cheatsheet <https://bashtage.github.io/sphinx-material/rst-cheatsheet/rst-cheatsheet.html>`_ for a handy reference on reStructuredText, the markup language used by Sphinx