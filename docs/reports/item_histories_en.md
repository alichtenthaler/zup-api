# Report history

A report now has a history with some important actions that occur.

## List history

The endpoint for listing/searching is: `GET /reports/items/:id/history`. If no filter parameter is passed, it will return all entries of the history paginated (by default 25 items per page).

The accepted parameters/filters are:

| Name       | Type    | Required   | Description                                                                     |
|------------|---------|------------|---------------------------------------------------------------------------------|
| user_id    | Integer | No         | The user id to be filtered.                                                     |
| kind       | String  | No         | The action type, can be: 'status', 'category', 'forward' and 'user_assign'.     |
| created_at | Object  | No         | Object with 'begin' and/or 'end' with dates in ISO-8601 format to be filtered.  |
| object_id  | Integer | No         | Object ID related to the history.                                            |

Example of parameters:

    /reports/items/90/history?user_id=1&kind=report

Example of return:

    {
      histories: [{
        "id": 1,
        "reports_item_id": 90,
        "user": {
          "id": 1,
          "name": "Ellie Welch IV",
          "groups": [...],
          "permissions": {...},
          "groups_names": [
            "Administradores"
          ]
        },
        "kind": "status",
        "action": "Mudou o status",
        "objects": [],
        "created_at": "2015-02-23T22:17:56.257-03:00"
      }, ...]
    }
