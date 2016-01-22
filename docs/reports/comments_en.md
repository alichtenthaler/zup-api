# Reports' comments

The reports can have comments created by both citizens and panel members.

## Content

* [Comment attributes](#attributes)
* [Create a comment](#create)
* [List comments](#list)


## Comment attributes <a name="attributes"></a>

An example of a JSON of a comment is:

    {
      "id": 1,
      "reports_item_id": 2,
      "visibility: 1,
      "author": {
        ...
      },
      "message": "Isso é um comentário"
      "created_at": ""
    }

## Create a comment <a name="create"></a>

To create a comment, use the following endpoint:

`POST /reports/:id/comments`

### Input parameters

| Name        | Type    | Required    | Description                           |
|-------------|---------|-------------|---------------------------------------|
| visibility* | Integer | Yes         | 0 = Public, 1 = Private, 2 = Internal |
| message     | String  | Yes         | The comment itself                    |

\* __How does the visibility work?__

* Public (0): All users can see this comment
* Private (1): Only the report author and the panel users can view
* Internal (2): Only the panel users can view this comment

### HTTP status

| Code | Description              |
|------|--------------------------|
| 400  | Invalid parameters.      |
| 401  | Unauthorized access.     |
| 201  | If successfully created. |


### Example of request

    {
      "visibility": 1,
      "message": "Esse relato é muito útil"
    }

## List comments <a name="list"></a>

To list comments from a report, use the following endpoint:

`GET /reports/:id/comments`
