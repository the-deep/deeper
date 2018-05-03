# Testing

> Author: [bibekdahal](https://github.com/bibekdahal)

Tests are written using Enzyme and Jest. Tests files are stored in the *\_\_tests\_\_* directory which lies inside the same directory as the component or logic that needs to be tested.

The following is an example of how to test if a component renders properly.

```javascript
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
```

If the initial setup is asynchronous, one may use `beforeEach` or `beforeAll` functions, both of which can return a promise object.

To test redux-connected components, one can use the `redux-mock-store`:

```javascript
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
```

More examples using redux: [writing tests](https://github.com/reactjs/redux/blob/master/docs/recipes/WritingTests.md).

For event based behavioral testing, Enzyme's `simulate` can be used as helper method.

```js
wrapper.find('button').simulate('click');
expect(wrapper.find('.no-of-clicks').text()).toBe('1');
```


