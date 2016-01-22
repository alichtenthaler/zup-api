# Group Permissions 

## Content
* [Return group permissions](#)
* [Add permission(s) in a group](#)
* [Remove permission of a group](#)

### Return permissions of a group 

To return permissions of a group, simply use the following endpoint:

    GET /groups/:group_id/permissions

the return of this request is the following:

    [
      {
        "permission_type": "inventory",
        "object": { // Inventory category info },
        "permission_names": ["inventory_categories_can_edit", "inventory_categories_can_view"]
      },
      {
        "permission_type": "report",
        "permission_names": "manage_reports"
      }
    ]

If there is no object property, permission is Boolean and the value is `true`.

### Add permission(s) in a group

To add one or more permissions to a group, use the following endpoint:

    POST /groups/:id/permissions/:permission_type

#### Parameters

| Name        | Type           | Required    | Description                                                   |
|-------------|----------------|-------------|---------------------------------------------------------------|
| objects_ids | Array[Integer] | No          | Array of ids of the objects related to the permissions        |
| permissions | Array[String]  | Yes         | Array of string with the permissions to be added to the group |

#### Available permission types

| Name      | Description       |
|-----------|-------------------|
| flow      | Cases and flows   |
| report    | Reports           |
| inventory | Inventory         |
| group     | Groups            |
| user      | Users             |
| other     | Other permissions |


This type must be expressed in the endpoint URL.

#### Example of request

    {
      "objects_ids": [1, 3],
      "permissions": ["inventory_categories_can_edit", "inventory_categories"]
    }

#### Example of return

    {
      message: "Permissões adicionadas com sucesso"
    }

### Remove permission of a group

To remove a permission of a group, use the following endpoint:

    DELETE /groups/:id/permissions/:permission_type

#### Parameters

| Name       | Type    | Required    | Description                                                   |
|------------|---------|-------------|---------------------------------------------------------------|
| permission | String  | Yes         | Permission name                                               |
| object_id  | Integer | No          | If the permission is related to an object, use this parameter |

#### Example of request

    {
      "permission": "inventory_categories_can_edit",
      "object_id": 2
    }

#### Example of return

    {
      "message": "Permissão removida com sucesso"
    }
