# Selection of inventory fields

For consistency of inventories of fields and items, a new structure was created to store and list the choices of inventory fields.

## Content

* [Attributes of inventory field](#attributes)
* [List choices of a field](#list)
* [Update a choice for a field] (#update)
* [Remove choice of a field] (#delete)


## Attributes of choice <a id="attributes"></a>

An example of inventory field in JSON is:

    {
      "id": 1,
      "inventory_field_id": 2,
      "disabled": false,
      "value": "Isso é uma escolha",
      "created_at": "..."
    }

## List choices of a field <a id="list"></a>

To list the choices for a field, use the following endpoint:

`GET /inventory/fields/:id/options`

## Create a choice for a field <a id="create"></a>

To create a choice for a field, use the following endpoint:

`POST /inventory/fields/:id/options`

### Input parameters

| Name   | Type         | Required    | Description                             |
|--------|--------------|-------------|-----------------------------------------|
| value  | String/Array | Yes         | The option value, or an array of values | 


### HTTP status of response 

| Code | Description            |
|------|------------------------|
| 400  | Invalid parameters.    |
| 401  | Unauthorized access.   |
| 201  | Successfully created.  |


### Example of request

    {
      "value": "Isto é uma escolha"
    }

## Update a choice for a field <a id="update"></a>

To update a choice for the field, use the following endpoint:

`PUT /inventory/fields/:field_id/options/:option_id`

### Input parameters

| Name    | Type  | Required    | Description      |
|--------|--------|-------------|------------------|
| value  | String | Yes         | The option value | 


### HTTP status of response 

| Code | Description            |
|------|------------------------|
| 400  | Invalid parameters.    |
| 401  | Unauthorized access.   |
| 200  | Successfully updated.  |


### Example of request

    {
      "value": "Isto é uma escolha com outro valor"
    }

## Remove choice of a field <a id="delete"></a>

To remove a choice for the field, use the following endpoint:

`DELETE /inventory/fields/:field_id/options/:option_id`

### HTTP status of response

| Code | Description            |
|------|------------------------|
| 401  | Unauthorized access.   |
| 200  | Successfully deleted.  |

> **Note**: this choice will not be truly removed, it is only deactivated to maintain consistency with inventory items that are referencing this choice.
