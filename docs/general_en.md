# General considerations

## Environment variables:

| Name                                     | Description                                                                                             | Default |
|------------------------------------------|---------------------------------------------------------------------------------------------------------|---------|
| `SERVER_WORKERS`                         | Passenger workers amount for the API                                                                    | 4       |
| `SMTP_ADDRESS`                           | SMTP server address for sending emails                                                                  |         |
| `SMTP_PORT`                              | SMTP server port                                                                                        |         |
| `SMTP_USER`                              | User for authentication to SMTP server                                                                  |         |
| `SMTP_PASS`                              | Password for authentication to SMTP server                                                              |         |
| `SMTP_TTLS`                              | Enable TTLS?                                                                                            | false   |
| `SMTP_AUTH`                              | Authentication type                                                                                     | plain   |
| `AWS_ACCESS_KEY_ID`                      | Passkey for AWS (upload access to S3)                                                                   |         |
| `AWS_SECRET_ACCESS_KEY`                  | Secret key of AWS account (upload access to S3)                                                         |         |
| `AWS_DEFAULT_IMAGE_BUCKET`               | S3 bucket name to be used                                                                               |         |
| `TWITTER_CONSUMER_KEY`                   | Twitter application key for OAuth authentication                                                        |         |
| `TWITTER_CONSUMER_SECRET`                | Twitter secret key for OAuth authentication                                                             |         |
| `FACEBOOK_APP_ID`                        | Facebook application key for OAuth authentication                                                       |         |
| `FACEBOOK_APP_SECRET`                    | Facebook secret key for OAuth authentication                                                            |         |
| `GOOGLE_CLIENT_ID`                       | Google application key for OAuth authentication                                                         |         |
| `GOOGLE_CLIENT_SECRET`                   | Google secret key for OAuth authentication                                                              |         |
| `APNS_PEM_PATH`                          | Path to the .pem file for iOS notifications                                                             |         |
| `APNS_PEM_PASS`                          | Password, if any, of the .pem file                                                                      |         |
| `GCM_KEY`                                | Google Cloud Messaging key for Android notifications                                                    |         |
| `REDIS_URL`                              | Full URL of Redis server                                                                                |         | 
| `API_URL`                                | Full URL, including port, where API will be hosted                                                      |         |
| `WEB_URL`                                | Full URL, including port, where the Painel component will be hosted                                     |         |
| `PUBLIC_WEB_URL`                         | Full URL, including port, where the Web component will be hosted                                        |         |
| `ASSET_HOST_URL`                         | Full URL where assets will be hosted                                                                    |         |
| `LIMIT_CITY_BOUNDARIES`                  | Limit reports and inventories by city                                                                   | false   |
| `GEOCODM`                                | City code in shapefile                                                                                  |         |
| `MAIL_HEADER_IMAGE`                      | Address for email header image                                                                          |         |
| `MAIL_CUSTOM_GREETINGS`                  | Greetings to all outgoing emails                                                                        |         |
| `MAIL_CUSTOM_GREETING_MESSAGE`           | Greeting message to all outgoing emails                                                                 |         |
| `MAXIMUM_REPORTS_PER_USER_BY_HOUR`       | Maximum number of reports per user, per hour                                                            |         |
| `MINIMUM_FLAGS_TO_MARK_REPORT_OFFENSIVE` | Minimum number of flags to mark a report as offensive                                                   |         |
| `SLACK_INCOMING_WEBHOOK_URL`             | Incoming Webhook URL, if you want notifications in a [Slack](http://slack.com) room                     |         |
| `SENTRY_DSN_URL`                         | Sentry DNS address, to add the exceptions, if you use [Sentry](http://getsentry.com)                    |         |
| `DISABLE_EMAIL_SENDING`                  | Disable API sending emails                                                                              |         |

## Choosing return fields

In all endpoints for listing (e.g. groups, inventory items, reports, categories, etc), you have the option to choose what fields you want to return from the API. This is done by setting the value of `return_fields` parameter in your request.

Suppose you wanted the following content for the inventory items:

    {
      items: [
        {
          id: 1,
          title: 'Árvores',
          user: {
            id: 1,
            name: 'Ricardo'
          }
        },
        {
          id: 2,
          title: 'Semáforos',
          user: {
            id: 2,
            name: 'Rita'
          }
        }
      ]
    }

Just pass the following parameter to the endpoint URL:

```
/inventory/items?return_fields=id,title,user.id,user.name
```

Note that the format is *a string with the field names separated by commas*.
Also, for nested contents, you must use the `.` separator. For example, the field `user.groups.name` is valid.

## Errors

There are several cases in which the API is expected to return errors. Basically, when an error occurs the response HTTP status is different from `200`.

The format of the error response returned by the API is as follows:

    {
      "error": "...", // Pode ser uma string com a mensagem de erro ou um objeto
      "type": "..." // Tipo do erro
    }

### HTTP status

The following error status can be returned by the API:

#### 403
The request failed due to lack of permission.

#### 401
The request failed due to parameter problems.

#### 404
Some necessary object was not found for the request response to be built.

#### 400
Problems on business logic validation.

### Error types

#### Not found (not_found)

An error is returned with the `type: "not_found"` if an entity required for the request to be answered has not been found.

Example of response:

    {
      "type": "not_found",
      "error": "Não foi encontrado"
    }

#### Validation error

If a validation error related to the business model occurs, an error with `type: "model_validation"` will be returned. In the `"error"` attribute is commonly found an object with the fields with validation failures.

Example of response:

    {
      "type": "model_validation",
      "error": {
        "name": "está vazio"
      }
    }

#### Permission error

If the user logged in is not authorized to perform the action proposed by the request, an error is returned with `type` equals to `invalid_permission`.

Example of response:

    {
      "type": "invalid_permission",
      "error": "Usuário não pode editar: grupo"
    }

#### Unknown error

If an unknown error occurs, the answer will come with `type` equal to `unknown` and `error` will have the error message:

Example of response:

    {
      "type": "unknown",
      "error": "Erro desconhecido ocorreu, contate o suporte"
    }
