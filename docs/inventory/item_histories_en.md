# History of inventory item

An inventory item now has an history with some important actions that occur.

## List historical

The endpoint for listing/searching is: `GET /inventory/items/:id/history`. In the case no filter parameters are passed, all history entries are returned paginated (25 items per page by default).

The accepted parameters/filters are:

| Name       | Type    | Required | Description                                                                              |
|------------|---------|----------|------------------------------------------------------------------------------------------|
| user_id    | Integer | No       | The user id you want to filter by.                                                       |
| kind       | String  | No       | The types of action can be: 'report', 'fields', 'images', 'flow', 'formula' or 'status'. |
| created_at | Object  | No       | Object containing 'begin' and/or 'end' with dates in ISO-8601 format for filtering.      |
| object_id  | Integer | No       | ID of the object related to the history                                                  |

Example of parameters:

    /inventory/items/90/history?user_id=1&kind=report

Example of return:

    {
      histories: [{
        "id": 1,
        "inventory_item_id": 90,
        "user": {
          "id": 1,
          "name": "Ellie Welch IV",
          "groups": [...],
          "permissions": {...},
          "groups_names": [
            "Administradores"
          ]
        },
        "kind": "report",
        "action": "Um relato foi solicitado",
        "objects": [],
        "created_at": "2015-02-23T22:17:56.257-03:00"
      }, ...]
    }

## History data with fields

If the history `kind` is `fields`, each entity of item history will return a `fields_changes` that will list the changes for each field.

Example of return:

    {
      histories: [{
        "id": 1,
        "inventory_item_id": 90,
        "user": {
          "id": 1,
          "name": "Ellie Welch IV",
          "groups": [...],
          "permissions": {...},
          "groups_names": [
            "Administradores"
          ]
        },
        "kind": "fields",
        "action": "Um relato foi solicitado",
        "objects": [{ //Dados do campo aqui }, { // Dados de outro campo aqui }],
        "fields_changes": {
          "field": { //Dado do campo },
          "previous_content": "conteúdo",
          "new_content": "conteúdo alterado"
        },
        "created_at": "2015-02-23T22:17:56.257-03:00"
      }, ...]
    }

### Important note:

If the field uses options for its content, `previous_content` and `new_content` will always be an array of ids.
