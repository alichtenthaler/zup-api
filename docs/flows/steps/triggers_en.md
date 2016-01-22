# ZUP-API documentation - Flows - Steps - Triggers

## Protocol

REST is the protocol used and JSON is received as parameter. It is required to perform authentication request and to use TOKEN to access the endpoint. It is also required to create a Step for proper use of this endpoint.

Endpoint Staging: `http://staging.zup.sapience.io/flows/:flow_id/steps/:step_id/triggers`

Example of how to carry out a request using cURL tool:

```bash
curl -X POST --data-binary @trigger-data.json -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows/:flow_id/steps/:step_id/triggers
```
Ou
```bash
curl -X POST --data-binary '{"campo":"valor"}' -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows/:flow_id/steps/:step_id/triggers
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

Endpoint: `/flows/:flow_id/steps/:step_id/triggers`

Method: get

#### Input Parameters

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

##### TriggerObject
| Name                  | Type       | Description                                                                                        |
|-----------------------|------------|----------------------------------------------------------------------------------------------------|
| id                    | Integer    | Object ID.                                                                                         |
| list_versions         | Array      | Array with all versions of the object.                                                             |
| created_at            | DateTime   | Date and time of the object creation.                                                              |
| updated_at            | DateTime   | Date and time of the object last update.                                                           |
| title                 | String     | Title of the object.                                                                               |
| action_type           | String     | Trigger action type (enable_steps disable_steps finish_flow transfer_flow) .                       |
| action_values         | Array      | Array of ID(s) according to trigger action type (step=Step ID, flow=Flow ID)                       |
| active                | Boolean    | If the object is active.                                                                           |
| version_id            | Integer    | Object version ID.                                                                                 |
| trigger_conditions    | Array      | Array of Trigger Conditions (vide TriggerConditionObject)                                          |
| my_trigger_conditions | Array      | Array of Trigger Conditions which version corresponds to the Trigger (vide TriggerConditionObject) |

##### TriggerConditionObject
| Name           | Type     | Description                                                                                  |
|----------------|----------|----------------------------------------------------------------------------------------------|
| id             | Integer  | Object ID.                                                                                   |
| list_versions  | Array    | Array with all versions of the object.                                                       |
| created_at     | DateTime | Date and time of the object creation.                                                        |
| updated_at     | DateTime | Date and time of the object last update.                                                     |
| condition_type | String   | Condition type (== != > < inc)                                                               |
| values         | Array    | Values IDs that should check the condition to be valid (more than one value only when "inc") |
| active         | Boolean  | If the object is active.                                                                     |
| version_id     | Integer  | Object version ID.                                                                           |
| my_field       | Object   | Field used in the Trigger condition.                                                         |

```json
{
  "triggers": [
    {
      "list_versions": null,
      "created_at": "2015-03-03T11:08:12.193-03:00",
      "updated_at": "2015-03-03T11:08:12.193-03:00",
      "id": 1,
      "title": "Gatilho 1",
      "trigger_conditions": [
        {
          "list_versions": null,
          "id": 1,
          "my_field": null,
          "condition_type": "==",
          "values": [
            1
          ],
          "active": true,
          "version_id": null,
          "updated_at": "2015-03-03T11:08:12.200-03:00",
          "created_at": "2015-03-03T11:08:12.200-03:00"
        }
      ],
      "my_trigger_conditions": [
        {
          "list_versions": null,
          "id": 1,
          "my_field": null,
          "condition_type": "==",
          "values": [
            1
          ],
          "active": true,
          "version_id": null,
          "updated_at": "2015-03-03T11:08:12.200-03:00",
          "created_at": "2015-03-03T11:08:12.200-03:00"
        }
      ],
      "action_type": "disable_steps",
      "action_values": [
        2
      ],
      "active": true,
      "version_id": null
    }
  ]
}
```
___

### Redefining Order <a name="order"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/triggers`

Method: put

#### Input Parameters

| Name | Type  | Required    | Description                                      |
|------|-------|-------------|--------------------------------------------------|
| ids  | Array | Yes         | Array with ids of Triggers in the desired order. | 

#### HTTP status

| Code | Description              |
|------|--------------------------|
| 400  | Invalid parameters.      |
| 401  | Unauthorized access.     |
| 200  | Display success message. |

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
  "message": "Ordem dos Gatilhos atualizado com sucesso"
}
```
___

### Creating <a name="create"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/triggers`

Method: post

#### Input Parameters

| Name                          | Type    | Required    | Description                                                         |
|-------------------------------|---------|-------------|---------------------------------------------------------------------|
| title                         | String  | Yes         | Title. (up to 100 characters)                                       |
| action_type                   | String  | Yes         | Action type. (enable_steps disable_steps finish_flow transfer_flow) |
| action_values                 | Array   | Yes         | Array with ids varying according to action_type                     |
| trigger_conditions_attributes | Array   | Yes         | Trigger Conditions (vide TriggerConditionsAttributes)               |


##### TriggerConditionsAttributes
| Name           | Type    | Required   | Description                                                               |
|----------------|---------|------------|---------------------------------------------------------------------------|
| field_id       | Integer | Yes        | Filed ID which will be used                                               |
| condition_type | String  | Yes        | Condition type (== != > < inc)                                            |
| values         | Array   | Yes        | Array of values to be compared (merely "inc" uses more than one value)    |

#### HTTP status

| Code | Description              |
|------|--------------------------|
| 400  | Invalid parameters.      |
| 401  | Unauthorized access.     |
| 201  | If successfully created. |

#### Example

##### Request
```json
{
  "title":"Titulo",
  "action_values":[1],
  "action_type":"disable_steps",
  "trigger_conditions_attributes":[
    {"field_id":1, "condition_type":"==", "values":[1]}
  ]
}
```

##### Response

| Name          | Type    | Description                                 |
|---------------|---------|---------------------------------------------|
| trigger       | Object  | Vide TriggerObject (get /triggers)          |

```
Status: 201
Content-Type: application/json
```

```json
{
  "trigger": {
    "list_versions": null,
    "created_at": "2015-03-03T11:08:12.193-03:00",
    "updated_at": "2015-03-03T11:08:12.193-03:00",
    "id": 1,
    "title": "Gatilho 1",
    "trigger_conditions": [
      {
        "list_versions": null,
        "id": 1,
        "my_field": null,
        "condition_type": "==",
        "values": [
          1
        ],
        "active": true,
        "version_id": null,
        "updated_at": "2015-03-03T11:08:12.200-03:00",
        "created_at": "2015-03-03T11:08:12.200-03:00"
      }
    ],
    "my_trigger_conditions": [
      {
        "list_versions": null,
        "id": 1,
        "my_field": null,
        "condition_type": "==",
        "values": [
          1
        ],
        "active": true,
        "version_id": null,
        "updated_at": "2015-03-03T11:08:12.200-03:00",
        "created_at": "2015-03-03T11:08:12.200-03:00"
      }
    ],
    "action_type": "disable_steps",
    "action_values": [
      2
    ],
    "active": true,
    "version_id": null
  },
  "message": "Gatilho criado com sucesso"
}
```
___

### Editing <a name="update"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/triggers/:id`

Method: put

#### Input Parameters

| Name                          | Type    | Required   | Description                                                          |
|-------------------------------|---------|------------|----------------------------------------------------------------------|
| title                         | String  | No         | Title. (up to 100 characters)                                        |
| action_type                   | String  | No         | Action type. (enable_steps disable_steps finish_flow transfer_flow)  |
| action_values                 | Array   | No         | Array with ids varying according to action_type                      |
| trigger_conditions_attributes | Array   | No         | Trigger Conditions (vide TriggerConditionsAttributes)                |


##### TriggerConditionsAttributes
| Name           | Type    | Required    | Description                                                             |
|----------------|---------|-------------|-------------------------------------------------------------------------|
| id             | Integer | No          | trigger_condition ID already exists or empty if new                     |
| field_id       | Integer | Yes         | Filed ID which will be used                                             |
| condition_type | String  | Yes         | Condition type (== != > < inc)                                          |
| values         | Array   | Yes         | Array of values to be compared (merely "inc" uses more than one value)  |

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
  "message": "Gatilho atualizado com sucesso"
}
```
___

### Deleting <a name="delete"></a>

Endpoint: `/flows/:flow_id/steps/:id/triggers/:id`

Method: delete

If any Case was created for the father Flow (you can check it with the GET option of the Flow and the attribute "total_cases")
the Trigger won't be deleted but inactivated, and if you do not have Cases it will be physically deleted.

#### Input Parameters

No input parameters, only **id** in the URL.

#### HTTP status

| Code | Description              |
|------|--------------------------|
| 401  | Unauthorized access.     |
| 404  | Does not exist.          |
| 200  | Successfully deleted.    |

#### Example

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Gatilho apagado com sucesso"
}
```
