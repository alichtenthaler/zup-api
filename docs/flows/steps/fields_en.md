# ZUP-API documentation - Flows - Steps - Triggers

## Protocol

REST is the protocol used and JSON is received as parameter. It is required to perform authentication request and to use TOKEN to access the endpoint. It is also required to create a Step for proper use of this endpoint.

Endpoint Staging: `http://staging.zup.sapience.io/flows/:flow_id/steps/:step_id/fields`

Example of how to carry out a request using cURL tool:

```bash
curl -X POST --data-binary @field-data.json -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows/:flow_id/steps/:step_id/fields
```
Ou
```bash
curl -X POST --data-binary '{"campo":"valor"}' -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows/:flow_id/steps/:step_id/fields
```

## Services

### Content

* [Listing](#list)
* [Creating](#create)
* [Editing](#update)
* [Deleting](#delete)
* [Redefining Order](#order)

___

### Listing <a name="list"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/fields`

Method: get

#### Input Parameters

| Name          | Type   | Required | Description                        |
|---------------|--------|----------|------------------------------------|
| display_type  | String | No       | To return all the data use 'full'. |

#### HTTP status

| Code | Description                              |
|------|------------------------------------------|
| 401  | Unauthorized access.                     |
| 200  | Listing is displayed (with zero or more) |

#### Example

##### Response
```
Status: 200
Content-Type: application/json
```

###### FieldObject
| Name                     | Type       | Description                                                                      |
|--------------------------|------------|----------------------------------------------------------------------------------|
| id                       | Integer    | Object ID.                                                                       |
| list_versions            | Array      | Array with all versions of the object.                                           |
| created_at               | DateTime   | Date and time of the object creation.                                            |
| updated_at               | DateTime   | Date and time of the object last update.                                         |
| title                    | String     | Title of the object.                                                             |
| previous_field           | Object     | Display previous field.                                                          |
| active                   | Boolean    | If the object is active.                                                         |
| field_type               | String     | Field type (vide types of fields in the Register)                                |
| origin_field_id          | Integer    | Source field ID (only if field_type is previous_field)                           |
| origin_field_version     | Integer    | Source field version ID (only if field_type is previous_field)                   |
| category_inventory       | Integer    | Inventory Item (only if field_type is category_inventory)                        |
| category_inventory_field | Integer    | Inventory Item Field (only if field_type is category_inventory_field)            |
| category_report          | Integer    | Report Item (only if field_type is category_report)                              |
| filter                   | Array      | Filters for inclusion, eg: "jpg,png" (only if field_type is image or attachment) |
| requirements             | Hash       | Requirements (presence, minimum/maximum)                                         |
| values                   | Hash       | Values (for type select, checkbox and radio), eg: {key:value, key:value}         |
| version_id               | Integer    | Object version ID.                                                               |

###### Requirements
| Name      | Type    | Description                                                  |
|-----------|---------|--------------------------------------------------------------|
| presence  | Boolean | If field is required                                         |
| minimum   | Integer | Minimum value of a field or minimum length of a text field   |
| maximum   | Integer | Maximum value of a field or maximum length of a text field   |

```json
{
  "fields": [
    {
      "list_versions": null,
      "last_version_id": null,
      "last_version": 1,
      "updated_at": "2014-05-17T13:40:18.039-03:00",
      "created_at": "2014-05-17T13:40:18.039-03:00",
      "active": true,
      "id": 1,
      "title": "age",
      "field_type": "integer",
      "filter": null,
      "origin_field": null,
      "category_inventory": null,
      "category_report": null,
      "requirements": null
    }
  ]
}
```
___

### Redefining Order <a name="order"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/fields`

Method: put

#### Input Parameters

| Name | Type  | Required | Description                                    |
|------|-------|----------|------------------------------------------------|
| ids  | Array | Yes      | Array with ids of fields in the desired order. |

#### Status HTTP

| Code | Description               |
|------|---------------------------|
| 400  | Invalid parameters.       |
| 401  | Unauthorized access.      |
| 200  | Display success message.  |

#### Example

##### Request

```json
{
  "ids": [3,1,2]
}
```

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Ordem dos Campos atualizado com sucesso"
}
```
___

### Creating <a name="create"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/fields`

Method: post

#### Input Parameters
 
| Name                  | Type    | Required  | Description                                                                      |
|-----------------------|---------|-----------|----------------------------------------------------------------------------------|
| title                 | String  | Yes       | Title. (up to 100 characters)                                                    |
| field_type            | String  | Yes       | Field type. (vide Field Types)                                                   |
| origin_field_id       | Integer | No        | Source field ID (only if field_type is previous_field)                           |
| category_inventory_id | Integer | No        | Inventory Item ID (only if field_type is category_inventory)                     |
| category_report_id    | Integer | No        | Report Item ID (only if field_type is category_report)                           |
| filter                | Array   | No        | Filters for inclusion, eg: "jpg,png" (only if field_type is image or attachment) |
| requirements          | Hash    | No        | Requirements (presence, minimum/maximum)                                         |
| values                | Hash    | No        | Values (for types select, checkbox and radio), eg: {key:value, key:value}        |

##### Field types
| Type                          | Description                                                      | Value to be used in filling Step Case                         |
|-------------------------------|------------------------------------------------------------------|---------------------------------------------------------------|
| angle                         | Angle (from 0 to 360º).                                          | Integer value with range from 0 to 360.                       |
| date                          | Date (dd/mm/yyyy).                                               | String value in date format dd/mm/yyyy.                       |
| time                          | Time (hh:mm:ss).                                                 | String value in time format hh:mm:ss.                         |
| cpf                           | CPF.                                                             | String value with or without dots.                            |
| cnpj                          | CNPJ.                                                            | String value with or without dots/slash.                      |
| url                           | URL.                                                             | String value with full URL format (with http(s)/ftp/udp).     |
| email                         | E-mail.                                                          | String value in e-mail format.                                |
| image                         | Image.                                                           | Hash array with file_name and content (image content base64). |
| attachment                    | Attachment.                                                      | Hash array with file_name and content (content base64).       |
| text                          | Text.                                                            | String value.                                                 |
| integer                       | Integer.                                                         | Integer value.                                                |
| decimal                       | Decimal.                                                         | Decimal/float value.                                          |
| meter                         | Meters.                                                          | Decimal/float value.                                          |
| centimeter                    | Centimeters.                                                     | Decimal/float value.                                          |
| kilometer                     | Kilometers.                                                      | Decimal/float value.                                          |
| year                          | Years.                                                           | Integer value.                                                |
| month                         | Months.                                                          | Integer value.                                                |
| day                           | Days.                                                            | Integer value.                                                |
| hour                          | Hours.                                                           | Integer value.                                                |
| minute                        | Minutes.                                                         | Integer value.                                                |
| second                        | Seconds.                                                         | Integer value.                                                |
| previous_field                | Previous field (field ID must be informed in origin_field_id).   | Value according to field type informed in origin_field_id.    |
| category_inventory            | Inventory categories (Category ID is required).                  | Array of selected inventory items IDs.                        |
| category_inventory_field      | Inventory Field (field ID must be informed in origin_field_id).  | Value according to field type informed in origin_field_id.    |
| category_report               | Reporting Categories (Category ID is required).                  | Array of selected reports IDs.                                |
| checkbox                      | Checkbox ('values' must be informed as {key:value,key:value}).   | Array of selected keys.                                       |
| select                        | Select ('values' must be informed as {key:value,key:value}).     | String value with the selected key.                           |
| radio                         | Radio ('values' must be informed as {key:value,key:value}).      | String value with the selected key.                           |


##### Requirements
| Name      | Type    | Required  | Description                                                  |
|-----------|---------|-----------|--------------------------------------------------------------|
| presence  | Boolean | No        | If field is required                                         |
| minimum   | Integer | No        | Minimum value of a field or minimum length of a text field   |
| maximum   | Integer | No        | Maximum value of a field or maximum length of a text field   |

#### HTTP status

| Code | Description              |
|------|--------------------------|
| 400  | Invalid parameters.      |
| 401  | Unauthorized access.     |
| 200  | If successfully created. |


#### Example

##### Request
```json
{
  "title":"age",
  "field_type":"integer"
}
```

##### Response
```
Status: 201
Content-Type: application/json
```

| Name         | Type   | Description                              |
|--------------|--------|-----------------------------------------|
| field        | Object | Field (vide FieldObject in get /fields) |

```json
{
  "field": {
    "list_versions": null,
    "previous_field": null,
    "created_at": "2015-03-03T13:30:29.082-03:00",
    "updated_at": "2015-03-03T13:30:29.082-03:00",
    "version_id": null,
    "active": true,
    "values": null,
    "id": 1,
    "title": "Campo 1",
    "field_type": "text",
    "filter": null,
    "origin_field_id": null,
    "category_inventory": null,
    "category_report": null,
    "requirements": {
      "presence": "true"
    }
  },
  "message": "Campo criado com sucesso"
}
```
___

### Editing <a name="update"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/fields/:id`

Method: put

#### Input Parameters

| Name                  | Type    | Required  | Description                                                                      |
|-----------------------|---------|-----------|----------------------------------------------------------------------------------|
| title                 | String  | Yes       | Title. (up to 100 characters)                                                    |
| field_type            | String  | Yes       | Field type. (vide Field Types)                                                   |
| origin_field_id       | Integer | No        | Source field ID (only if field_type is previous_field)                           |
| category_inventory_id | Integer | No        | Inventory Item ID (only if field_type is category_inventory)                     |
| category_report_id    | Integer | No        | Report Item ID (only if field_type is category_report)                           |
| filter                | Array   | No        | Filters for inclusion, eg: "jpg,png" (only if field_type is image or attachment) |
| requirements          | Hash    | No        | Requirements (presence, minimum/maximum)                                         |
| values                | Hash    | No        | Values (for types select, checkbox and radio), eg: {key:value, key:value}        |


##### Field types
| Type                          | Description                                                            |
|-------------------------------|------------------------------------------------------------------------|
| angle                         | Angle (from 0 to 360º).                                                | 
| date                          | Date (dd/mm/yyyy).                                                     | 
| time                          | Time (hh:mm:ss).                                                       | 
| cpf                           | CPF.                                                                   | 
| cnpj                          | CNPJ.                                                                  | 
| url                           | URL.                                                                   | 
| email                         | E-mail.                                                                | 
| image                         | Image.                                                                 | 
| attachment                    | Attachment.                                                            | 
| text                          | Text.                                                                  | 
| integer                       | Integer.                                                               | 
| decimal                       | Decimal.                                                               | 
| meter                         | Meters.                                                                | 
| centimeter                    | Centimeters.                                                           | 
| kilometer                     | Kilometers.                                                            | 
| year                          | Years.                                                                 | 
| month                         | Months.                                                                | 
| day                           | Days.                                                                  | 
| hour                          | Hours.                                                                 | 
| minute                        | Minutes.                                                               | 
| second                        | Seconds.                                                               | 
| previous_field                | Previous field (field ID must be informed in origin_field_id).         | 
| category_inventory            | Inventory field (field ID must be informed in category_inventory_id).  | 
| category_report               | Report field (field ID must be informed in category_report_id).        | 
| checkbox                      | Checkbox ('values' must be informed as {key:value,key:value}).         |
| select                        | Select ('values' must be informed as {key:value,key:value}).           | 
| radio                         | Radio ('values' must be informed as {key:value,key:value}).            | 

##### Requirements
| Name      | Type    | Required  | Description                                                  |
|-----------|---------|-----------|--------------------------------------------------------------|
| presence  | Boolean | No        | If field is required                                         |
| minimum   | Integer | No        | Minimum value of a field or minimum length of a text field   |
| maximum   | Integer | No        | Maximum value of a field or maximum length of a text field   |


#### HTTP status

| Code | Description              |
|------|--------------------------|
| 400  | Invalid parameters.      |
| 401  | Unauthorized access.     |
| 404  | Does not exist.          |
| 200  | If successfully updated. |

#### Example

##### Request
```json
{
  "title": "Novo Título"
}
```

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Campo atualizado com sucesso"
}
```
___

### Deleting <a name="delete"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/fields/:id`

Method: delete

If any Case was created for the father Flow Step Field (you can check it with the GET option of the Flow and the attribute "total_cases")
the Field Condition won't be deleted but inactivated, and if you do not have Cases it will be physically deleted.

#### Input Parameters

No input parameters, only **id** in the URL.

#### HTTP status

| Code | Description              |
|------|--------------------------|
| 401  | Unauthorized access.     |
| 404  | Does not exist.          |
| 200  | If successfully deleted. |

#### Example

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Campo apagado com sucesso"
}
```
