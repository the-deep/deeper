
💡 Testing
++++++++++++

Backend
========


Tests are written using django/django-rest test classes. Tests files are stored in the *tests* directory which lies inside each app and utils module.

      ▾ docs/
          mixin_backend.md
      ▾ backend/
          ▾ project/
            ▾ tests/
              __init__.py
              test_apis.py


The following is an example for testing django-rest API:

**backend/project/tests/test_apis.py**

**python**

from rest_framework.test import APITestCase
from user.tests.test_apis import AuthMixin
from project.models import Project

  .. code-block:: bash  

    class ProjectMixin():
        """
        Project related methods
        """

        def create_or_get_project(self):
            """
            Create new or return recent projects
            """
            project = Project.objects.first()
            # ...
            return project


    class ProjectApiTest(AuthMixin, ProjectMixin, APITestCase):
        """
        Project Api Test
        """

        def setUp(self):
            pass

        def test_create_project(self):
            pass


**The following is an example for testing utils:**

**backend/project/tests/test_apis.py**

 .. code-block:: bash  

  from django.test import TestCase
  from utils.extractors import (
      PdfExtractor, DocxExtractor, PptxExtractor
  )
  
  class ExtractorTest(TestCase):
      """
      Import Test
      Pdf, Pptx and docx
      Note: Html test is in WebDocument Test
      """
      def setUp(self):
          pass
  
      def extract(self, extractor, path):
          pass
  
      def test_docx(self):
          """
          Test Docx import
          """
          pass
  

**References:**

[Writing Django tests](https://docs.djangoproject.com/en/1.11/topics/testing/overview/)

[Writing API tests](http://www.django-rest-framework.org/api-guide/testing/)

[Test Mixin](mixin_backend.md)

FrontEnd
========
# Testing


Tests are written using Enzyme and Jest. Tests files are stored in the *\_\_tests\_\_* directory which lies inside the same directory as the component or logic that needs to be tested.

The following is an example of how to test if a component renders properly.

 .. code-block:: bash  

   // components/Table/__tests__/index.js
   
   import React from 'react';
   import { shallow } from 'enzyme';
   import Table from '../index';
   
   // Describe a test suite: a group of related tests
   describe('<Table />', () => {
       // Initial setup (synchronous)
       const tableData = [
           { a: 'b', c: 'd' },
           { a: 'e', c: 'f' },
       ];
       const tableHeaders = [
           { a: '1', c: '2' },
       ];
   
       const wrapper = shallow(
           <Table
               data={tableData}
               headers={tableHeaders}
           />,
       );
   
       // Test if it renders
       it('renders properly', () => {
           expect(wrapper.length).toEqual(1);
       });
   
       // More tests
       // ...
   });

If the initial setup is asynchronous, one may use `beforeEach` or `beforeAll` functions, both of which can return a promise object.

To test redux-connected components, one can use the `redux-mock-store`:

.. code-block:: bash  

    import React from 'react';
    import { Provider } from 'react-redux';
    import configureStore from 'redux-mock-store';
    import { shallow } from 'enzyme';
    import Table from '../index';

    describe('<Table />', () => {
        const mockStore = configureStore();
        const store = mockStore(initialState);
        const wrapper = shallow(<Provider store={store}><Table /></Provider>);

        it('renders properly', () => {
            expect(wrapper.length).toEqual(1);
            expect(wrapper.prop('someProp').toEqual(initialState.someProp);
        });

    });

More examples using redux: [writing tests](https://github.com/reactjs/redux/blob/master/docs/recipes/WritingTests.md).

For event based behavioral testing, Enzyme's `simulate` can be used as helper method.

.. code-block:: bash  

  wrapper.find('button').simulate('click');
  expect(wrapper.find('.no-of-clicks').text()).toBe('1');
  



