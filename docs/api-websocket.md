# Websocket API

Websockets are used by clients to subscribe and unsubscribe to different events in the server. Once subscribed, the server will notify the client whenever the subscribed event occurs.

> In each request, a sequence number needs to be provided with the key `sn` and the client should expect
the response to contain the same sequence number.

## Authroization and Connection

Connect to the subscription endpoint at the following path. The client must pass an *access_token* available through the REST API...

```
/subscribe/?jwt=<access_token>
```

This *access_token* is used for user authorization and for checking user permissions in subsequent requests.

## Heartbeat Requests

A simple json request with `action` set to `hb`:

```json
{
    "sn": 123,
    "action": "hb"
}
```

The response should include a timestamp nothing else:

```json
{
    "sn": 123,
    "timestamp": "2017-09-24T12:41:54.131068Z"
}
```

## Subscription Requests

A JSON request needs to sent be on a connected socket endpoint along with information of the channel and the event for which
the user wants to be notified.

```json
{
    "sn": 123,
    "action": "subscribe",
    "channel": "<channel_name>",
    "event": "<event_name>",
    "<other_params...>"
}
```

Expected response:
```json
{
    "sn": 123,
    "success": true,
    "code": "<subscription_code>"
}
```


*Available channels, events and their corresponding parameters are listed at the bottom of this documentation.*


## Unsubscribe Requests

To unsubscribe to all events:

```json
{
    "sn": 123,
    "action": "unsubscribe",
    "channel": "all"
}
```

To unsubscribe to particular event:
```json
{
    "sn": 123,
    "action": "unsubscribe",
    "channel": "<channel_name>",
    "event": "<event_name>",
    "<other_params...>"
}
```

Expected response:

```json
{
    "sn": 123,
    "success": true,
    "unsubscribed_codes": ["<list_of_subscription_codes>"]
}
```

## Error Response

When an error is encountered, `success: false` is sent along with the `error_code` and the actual `error` message.

```json
{
    "sn": 123,
    "success": false,
    "error_code": 403,
    "error": "Permission denied"
}
```


Some common error codes are as follows:

* 403 : Permission denied

* 40011 : Sequence number not provided
* 40012 : Action not provided or invalid
* 40021 : Channel not provided or invalid
* 40022 : Event not provided or invalid
* 40023 : Field not provided or invalid

* 4001 : Invalid token or no user associated with the provided JWT
* 4012 : Authentication failed; may need to reconnect to endpoint using proper JWT
* 4013 : User is marked inactive
* 4014 : User not found or has been removed


## List of Subscription Channels and Events

The following are all in the form:

```
* channel_name
    * event1_name
        * parameter1
        * parameter2
    * event2_name
* ...
```

```
* leads
    * onNew
        * projectId
    * onEdited
        * leadId
    * onPreviewExtracted
        * leadId
```
