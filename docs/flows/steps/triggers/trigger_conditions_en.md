# ZUP-API documentation - Flows - Steps - Triggers

## Protocol

REST is the protocol used and JSON is received as parameter. It is required to perform authentication request and to use TOKEN to access the endpoint. It is also required to create a Trigger with at least one Condition for proper use of this endpoint. 

*For creating and updating is used in the PUT of the Trigger.

Endpoint Staging: `http://staging.zup.sapience.io/flows/:flow_id/steps/:step_id/triggers/:trigger_id/trigger_conditions`

Example of how to carry out a request using cURL tool:

```bash
curl -X DELETE -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows/:flow_id/steps/:step_id/triggers/:trigger_id/trigger_conditions/:trigger_condition_id
```

## Services

### Content

* [Deleting](#delete)

___

### Deleting <a name="delete"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/triggers/:trigger_id/trigger_conditions/:id`

Method: delete

If any Case was created for the father Flow Step Trigger (you can check it with the GET option of the Flow and the attribute "total_cases")
the Trigger Condition won't be deleted but inactivated, and if you do not have Cases it will be physically deleted.

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
  "message": "Condição do Gatilho apagado com sucesso"
}
```
