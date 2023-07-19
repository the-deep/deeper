
📚 API Reference
+++++++++++++++++


Deep uses both GraphQL and REST.
Most of the platform uses GraphQL but there are some parts where we still use 
REST which we are trying to migrate from as well.

REST Endpoints
------------------

Rest API Endpoints can be found here  : https://prod-api.thedeep.io/api-docs/


GraphQL Endpoints
--------------------

GraphQL Endpoints points can be found here  : https://prod-api.thedeep.io/graphql-docs/

REST API
----------

A thorough documentation of the API itself can be found at */api-docs/*.

**Authentication**

For the core deep, client -> backend, we use session-based authentication instead.
Most of the external clients use basic auth for now.

Types of tokens
----------------

**Access Tokens**
 
 This is sent in all types of API requests for authorization. It is a fast authentication and doesn't check for scenarios such as if a user has changed their password. This token typically expires every hour.

 If an invalid or expired token is provided, a 401 error with message **"Token is invalid or expired"** is returned in the response.

.. code-block:: bash 

    {
        "errorCode": 4012,
        "errors": "Token is invalid or expired",
        "timestamp": "2017-09-24T06:49:59.699010Z"
    }

**Refresh Tokens**

This is a long lasting token, typically lasting one week. It is used to obtain new access tokens. It also performs thorough authentication before handing out new access tokens.

An expired or invalid refresh token gives 400 error.

.. code-block:: bash 

 {
     "errorCode": 4001,
     "errors": {
         "nonFieldErrors": [
             "Token is invalid or expired"
         ]
     },
     "timestamp": "2017-09-24T06:49:59.699010Z"
 }


**Response Formats**

On success (200 or 201 responses), the body of the response contains the requested resource.

On error, the http status code will represent the type of error and the body of the response contains the internal server error code and an error message.

A json object `errors` is also returned. It indicates a key-value pair for each field error in user request as well as a list of non-field-errors.

.. code-block:: bash 

 {
     "timestamp": "2017-09-24T06:49:59.699010Z",
 	"errorCode": 400,
     "errors": {
         "username": "This field may not be blank.",
         "password": "This field may not be blank.",
     	"nonFieldErrors": [
             "You do not permission to modify this resource."
         ]
     }
 }

**Pagination and filtering**

If an API returns a list of results, it is possible to query only a subset of those results using query parameters.

You can use the `limit` and `offset` query parameters to indicate the number of results to return as well as the
initial index from which to return the results.

The order of the results can be unique to each API. However, if the resource returned by the API
has modified `modifiedAt` or `createdAt` fields, and unless anything else is explicitly defined for that
API, the results are usually ordered first by `modifiedAt` and then `createdAt`.

The list API response always contains the `count` and `results` fields where `count` is the total number
of items available (not considering the limit and offset) and `results` is the actual list of items queried.
The API can also contain the `next` and `previous` fields indicating the URL to retrieve the next and previous set of items of the same count.

Example request:


GET /api/v1/leads/?offset=0&limit=1

Example response:

.. code-block:: bash

 {
     "count": 2,
     "next": "http://localhost:8000/api/v1/leads/?limit=1&offset=1",
     "previous": null,
     "results": [
         {
             "id": 1,
             "createdAt": "2017-09-29T12:23:18.009158Z",
             "modifiedAt": "2017-09-29T12:23:18.016450Z",
             "createdBy": 1,
             "modifiedBy": 1,
             "title": "Test",
             "source": "Test source",
             "confidentiality": "unprotected",
             "status": "pending",
             "publishedOn": null,
             "text": "This is a test lead and is a cool one.",
             "url": "",
             "website": "",
             "attachment": null,
             "project": 4,
             "assignee": [
                 1
             ]
         }
     ]
 }

Many APIs also take further query parameters to filter the query set. For example, you can filter Sources by projects using:

.. code-block:: bash

  GET /api/v1/leads/?project=2


The API documentation at */api/v1/docs/* also lists filters available for each API.

**Ordering**

To order the results by a particular field, one can use the `ordering` filter. By default, *ascending* is used, but *descending* can be enforced by using minus (-) sign with the field.

.. code-block:: bash

 GET /api/v1/leads/?ordering=title
 GET /api/v1/leads/?ordering=-title


**Camel Case vs Snake Case**

The JSON requests and responses are, by default, in camel case. JSON requests in snake case are also
supported. However, the filtering and ordering parameters need to be in snake case. This is because
they need to directly correspond to proper sql column names, which by convention are in snake case.

**HTTP Status Codes**

**Successful Requests:**

* 201 :	When a new resource is created. Normally for POST requests only.
* 200 :	For any other successful requests.

**Client Errors:**

* 400 :	Bad request: the json request doesn't contain proper fields
* 401 :	Unauthorized: needs a logged in user
* 403 :	Forbidden: user does not have permission for the requested resource
* 404 :	Resource is not found in the database
* 405 :	Not a valid HTTP method

**Server Errors:Server Errors:**

* 500 :	See internal error code below for actual error

Other codes like 502, 504 etc. may be unintentionally raised by nginx, WSGI, or DNS servers for which the web server is not responsible.

**Internal Error Codes**

For most types of errors like forbidden, unauthorized and not found, the internal error code returned is the same as the HTTP status code.

For server errors, all except the following lists of predefined errors will have internal error code 500 by default.

* 4011 : User is not authenticated. Access token is required in the authorization header.
