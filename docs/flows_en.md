# ZUP-API Documentation - Flows

## Protocol

The adopted protocol is REST, and a JSON is received as the input parameter. It is necessary to perform an authentication request and to use a TOKEN in the requests to this Endpoint.

Endpoint Staging: `http://staging.zup.sapience.io/flows`

Example of how to carry out a request using cURL tool:

```bash
curl -X POST --data-binary @flows-data.json -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows
```
Or
```bash
curl -X POST --data-binary '{"campo":"valor"}' -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows
```

## Services

### Content

* [List Flow](#list)
* [Create Flow](#create)
* [Display Flow](#show)
* [Publish Flow](#publish)
* [Change Current Version](#change_version)
* [Edit Flow](#update)
* [Delete Flow](#delete)
* [Add Permission](#permission_add)
* [Remove Permission](#permission_rem)

___

### Listing Flows <a name="list"></a>

Endpoint: `/flows`

Method: get

#### Input parameters

| Name          | Type    | Required   | Description                                           |
|---------------|---------|------------|-------------------------------------------------------|
| initial       | Boolean | No         | To return initial flows.                              |
| display_type  | String  | No         | To return all the values use the parameter as 'full'. |

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

| Name   | Type    | Description                                    |
|--------|---------|------------------------------------------------|
| flows  | Array   | Array of flows (see FlowObject get /flows/:id) |

```json
{
  "flows": [
    {
      "list_versions": [
        {
          "created_at": "2015-03-04T00:30:40.425-03:00",
          "my_resolution_states": [],
          "resolution_states": [],
          "steps_id": [],
          "steps_versions": {},
          "initial": false,
          "description": null,
          "title": "Fluxo Filho",
          "id": 4,
          "resolution_states_versions": {},
          "status": "pending",
          "draft": false,
          "total_cases": 0,
          "version_id": 2,
          "created_by_id": 1,
          "updated_by_id": 1,
          "updated_at": "2015-03-04T00:31:03.225-03:00"
        }
      ],
      "created_at": "2015-03-04T00:30:40.425-03:00",
      "my_resolution_states": [],
      "resolution_states": [],
      "steps_id": [],
      "steps_versions": {},
      "initial": false,
      "description": null,
      "title": "Fluxo Filho",
      "id": 4,
      "resolution_states_versions": {},
      "status": "pending",
      "draft": false,
      "total_cases": 0,
      "version_id": null,
      "created_by_id": 1,
      "updated_by_id": 1,
      "updated_at": "2015-03-04T00:31:03.225-03:00"
    },
    {
      "list_versions": [
        {
          "created_at": "2015-03-04T00:17:01.471-03:00",
          "my_resolution_states": [],
          "resolution_states": [
            {
              "list_versions": null,
              "created_at": "2015-03-04T02:08:10.302-03:00",
              "updated_at": "2015-03-04T02:08:10.302-03:00",
              "version_id": null,
              "active": true,
              "default": true,
              "title": "Resolução 1",
              "id": 1
            }
          ],
          "steps_id": [
            "6",
            "5",
            "4"
          ],
          "steps_versions": {
            "6": 7,
            "5": 6,
            "4": 4
          },
          "initial": false,
          "description": null,
          "title": "Fluxo Inicial",
          "id": 3,
          "resolution_states_versions": {},
          "status": "pending",
          "draft": false,
          "total_cases": 0,
          "version_id": 8,
          "created_by_id": 1,
          "updated_by_id": 1,
          "updated_at": "2015-03-04T00:52:08.985-03:00"
        }
      ],
      "created_at": "2015-03-04T00:17:01.471-03:00",
      "my_resolution_states": [
        {
          "list_versions": null,
          "created_at": "2015-03-04T02:08:10.302-03:00",
          "updated_at": "2015-03-04T02:08:10.302-03:00",
          "version_id": null,
          "active": true,
          "default": true,
          "title": "Resolução 1",
          "id": 1
        }
      ],
      "resolution_states": [
        {
          "list_versions": null,
          "created_at": "2015-03-04T02:08:10.302-03:00",
          "updated_at": "2015-03-04T02:08:10.302-03:00",
          "version_id": null,
          "active": true,
          "default": true,
          "title": "Resolução 1",
          "id": 1
        }
      ],
      "steps_id": [
        "6",
        "5",
        "4"
      ],
      "steps_versions": {
        "6": 7,
        "5": 6,
        "4": 4
      },
      "initial": false,
      "description": null,
      "title": "Fluxo Inicial",
      "id": 3,
      "resolution_states_versions": {
        "1": null
      },
      "status": "active",
      "draft": true,
      "total_cases": 0,
      "version_id": null,
      "created_by_id": 1,
      "updated_by_id": 1,
      "updated_at": "2015-03-04T02:08:10.320-03:00"
    },
    {
      "list_versions": null,
      "created_at": "2015-03-04T02:22:55.397-03:00",
      "my_resolution_states": [],
      "resolution_states": [],
      "steps_id": [],
      "steps_versions": {},
      "initial": false,
      "description": null,
      "title": "Fluxo Filho",
      "id": 5,
      "resolution_states_versions": {},
      "status": "pending",
      "draft": true,
      "total_cases": 0,
      "version_id": null,
      "created_by_id": 1,
      "updated_by_id": null,
      "updated_at": "2015-03-04T02:22:55.397-03:00"
    }
  ]
}
```
___

### Create Flow <a name="create"></a>

Endpoint: `/flows`

Method: post

#### Input Parameters

| Name                  | Type    | Required  | Description                                    |
|-----------------------|---------|-----------|------------------------------------------------|
| title                 | String  | Yes       | Flow title. (up to 100 characters)             |
| description           | Text    | No        | Flow description. (up to 600 characters)       |
| initial               | Boolean | No        | To define a flow as initial.                   |
| resolution_states     | Array   | No        | Set of resolution states (see fields below).   |

#### Parameters for resolution states

| Name                  | Type    | Required  | Description                                             |
|-----------------------|---------|-----------|---------------------------------------------------------|
| title                 | String  | Yes       | Flow title. (up to 100 characters)                      |
| default               | Boolean | No        | If true, new cases are created with this state.         |
| active                | Boolean | No        | If false, state has been deleted and can not be used.   |


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
  "title": "Título do Fluxo",
  "description": "Descrição para o Fluxo"
}
```

##### Response
```
Status: 201
Content-Type: application/json
```

| Nome        | Tipo    | Descrição                                |
|-------------|---------|------------------------------------------|
| flow        | Object  | Vide FlowObject get /flows/:id           |

```json
{
  "flow": {
    "list_versions": null,
    "created_at": "2015-03-04T02:22:55.397-03:00",
    "updated_at": "2015-03-04T02:22:55.397-03:00",
    "updated_by": null,
    "created_by": {
      "google_plus_user_id": null,
      "twitter_user_id": null,
      "document": "67392343700",
      "phone": "11912231545",
      "email": "euricovidal@gmail.com",
      "groups_names": [
        "Administradores"
      ],
      "permissions": {
        "flow_can_delete_own_cases": [],
        "flow_can_delete_all_cases": [],
        "create_reports_from_panel": true,
        "updated_at": "2015-03-03T10:45:07.465-03:00",
        "created_at": "2015-03-03T10:45:07.461-03:00",
        "view_categories": false,
        "edit_reports": true,
        "edit_inventory_items": true,
        "delete_reports": false,
        "delete_inventory_items": false,
        "manage_config": true,
        "manage_inventory_formulas": true,
        "manage_reports": true,
        "id": 2,
        "group_id": 2,
        "manage_flows": true,
        "manage_users": true,
        "manage_inventory_categories": true,
        "manage_inventory_items": true,
        "manage_groups": true,
        "manage_reports_categories": true,
        "view_sections": false,
        "panel_access": true,
        "groups_can_edit": [],
        "groups_can_view": [],
        "reports_categories_can_edit": [],
        "reports_categories_can_view": [],
        "inventory_categories_can_edit": [],
        "inventory_categories_can_view": [],
        "inventory_sections_can_view": [],
        "inventory_sections_can_edit": [],
        "inventory_fields_can_edit": [],
        "inventory_fields_can_view": [],
        "flow_can_view_all_steps": [],
        "flow_can_execute_all_steps": [],
        "can_view_step": [],
        "can_execute_step": []
      },
      "groups": [
        {
          "permissions": {
            "flow_can_delete_own_cases": [],
            "flow_can_delete_all_cases": [],
            "create_reports_from_panel": true,
            "updated_at": "2015-03-03T10:45:07.465-03:00",
            "created_at": "2015-03-03T10:45:07.461-03:00",
            "view_categories": false,
            "edit_reports": true,
            "edit_inventory_items": true,
            "delete_reports": false,
            "delete_inventory_items": false,
            "manage_config": true,
            "manage_inventory_formulas": true,
            "manage_reports": true,
            "id": 2,
            "group_id": 2,
            "manage_flows": true,
            "manage_users": true,
            "manage_inventory_categories": true,
            "manage_inventory_items": true,
            "manage_groups": true,
            "manage_reports_categories": true,
            "view_sections": false,
            "panel_access": true,
            "groups_can_edit": [],
            "groups_can_view": [],
            "reports_categories_can_edit": [],
            "reports_categories_can_view": [],
            "inventory_categories_can_edit": [],
            "inventory_categories_can_view": [],
            "inventory_sections_can_view": [],
            "inventory_sections_can_edit": [],
            "inventory_fields_can_edit": [],
            "inventory_fields_can_view": [],
            "flow_can_view_all_steps": [],
            "flow_can_execute_all_steps": [],
            "can_view_step": [],
            "can_execute_step": []
          },
          "name": "Administradores",
          "id": 2
        }
      ],
      "name": "Hellen Armstrong Sr.",
      "id": 1,
      "address": "430 Danika Parkways",
      "address_additional": "Suite 386",
      "postal_code": "04005000",
      "district": "Lake Elsafort",
      "device_token": "445dcfb912fade983885d17f9aa42448",
      "device_type": "ios",
      "created_at": "2015-03-03T10:45:08.037-03:00",
      "facebook_user_id": null
    },
    "steps_versions": {},
    "my_steps_flows": [],
    "my_steps": [],
    "steps": [],
    "initial": false,
    "description": null,
    "title": "Fluxo Filho",
    "id": 5,
    "resolution_states": [],
    "my_resolution_states": [],
    "resolution_states_versions": {},
    "status": "pending",
    "draft": true,
    "total_cases": 0,
    "version_id": null,
    "permissions": {
      "flow_can_delete_all_cases": [],
      "flow_can_delete_own_cases": [],
      "flow_can_execute_all_steps": [],
      "flow_can_view_all_steps": []
    }
  },
  "message": "Fluxo criado com sucesso"
}
```
___

### Edit Flow <a name="update"></a>

Endpoint: `/flows/:id`

Method: put

#### Input Parameters


| Name                  | Type    | Required  | Description                                    |
|-----------------------|---------|-----------|------------------------------------------------|
| title                 | String  | Yes       | Flow title. (up to 100 characters)             |
| description           | Text    | No        | Flow description. (up to 600 characters)       |
| initial               | Boolean | No        | To define a flow as initial.                   |
| resolution_states     | Array   | No        | Set of resolution states (see fields below).   |

#### Parameters for resolution states

| Name                  | Type    | Required  | Description                                             |
|-----------------------|---------|-----------|---------------------------------------------------------|
| title                 | String  | Yes       | Flow title. (up to 100 characters)                      |
| default               | Boolean | No        | If true, new cases are created with this state.         |
| active                | Boolean | No        | If false, state has been deleted and can not be used.   |


#### HTTP status

| Code | Description                       |
|------|-----------------------------------|
| 400  | Invalid parameters.               |
| 401  | Unauthorized access.              |
| 404  | Flow does not exist.              |
| 200  | If Flow was successfully updated. |


#### Example

##### Request
```json
{
  "title": "Novo Título do Fluxo"
}
```

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Fluxo atualizado com sucesso"
}
```
___

### Delete Flow <a name="delete"></a>

Endpoint: `/flows/:id`

Method: delete

If there are any Cases created for the Flow (you can check it with the GET option of the Flow and with the attribute "total_cases"), the Flow will be inactivated instead of deleted. If there are no Cases, it will be physically deleted.

#### Input Parameters

No input parameters, only **id** in the URL.

#### HTTP status

| Code | Description                         |
|------|-------------------------------------|
| 401  | Unauthorized access.                |
| 404  | Flow does not exist.                |
| 200  | If Flow wasSuccessfully deleted.    |


#### Example

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Fluxo apagado com sucesso"
}
```
___

### Display Flow <a name="show"></a>

Endpoint: `/flows/:id`

Method: get

#### Input Parameters


| Name          | Type     | Required  | Description                                             |
|---------------|----------|-----------|---------------------------------------------------------|
| version       | Integer  | No        | Flow version, when current version is not the last one. |
| display_type  | String   | No        | To return all the values use the parameter as 'full'.   |


#### HTTP status

| Code | Description                     |
|------|---------------------------------|
| 401  | Unauthorized access.            |
| 404  | Flow does not exist.            |
| 200  | Display the searched Flow.      |


#### Example

##### Response
```
Status: 200
Content-Type: application/json
```

###### FlowObject

| Name                       | Type       | Description                                                                                                                                                                                |
|----------------------------|------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| id                         | Integer    | Object ID.                                                                                                                                                                                 |
| list_versions              | Array      | Array with all versions of the object.                                                                                                                                                     |
| created_by                 | Object     | Object of the user who created the Flow.                                                                                                                                                   |
| updated_by                 | Object     | Object of the user who updated the Flow.                                                                                                                                                   |
| created_at                 | DateTime   | Date and time of the object creation.                                                                                                                                                      |
| updated_at                 | DateTime   | Date and time of the object's last update.                                                                                                                                                 |
| title                      | String     | Object title.                                                                                                                                                                              |
| description                | String     | Object description.                                                                                                                                                                        |
| status                     | String     | Flow status (active, inactive, pending).                                                                                                                                                   |
| initial                    | Boolean    | Whether the Flow is initial or not (Case can only be created with initial Flow).                                                                                                           |
| draft                      | Boolean    | Whether the flow is as a draft and needs to be published (any change to the Flow or to the derivatives define the Flow as Draft and needs to be published in order to generate a version). |
| resolution_states          | Array      | Array of Resolution States (see ResolutionStateObject get /flows/1/resolution_states).                                                                                                     |
| my_resolution_states       | Array      | Array of Resolution States with version corresponding to the Flow (see ResolutionStateObject get /flows/1/resolution_states).                                                              |
| version_id                 | Integer    | Object version ID.                                                                                                                                                                         |
| permissions                | Object     | Permission list (the key represents the permission and the value is an array of group IDs).                                                                                                |
| total_cases                | Integer    | Total of Cases using the Flow or a Flow Step (if Flow is not initial).                                                                                                                     |
| steps                      | Array      | Array of Steps with the latest version of Step (for editing as it might be being modified and be in draft mode. See StepObject get /flows/1/steps/1).                                      |
| my_steps                   | Array      | Array of Steps with version corresponding to the Flow (see StepObject get /flows/1/steps/1).                                                                                               |
| steps_versions             | Array      | Array of Hash with the key representing the Step ID and the value representing the Version ID (displaying the order of the Steps).                                                         |
| resolution_states_versions | Array      | Array of Hash with the key representing the Resolution State ID and the value representing the Version ID.                                                                                 |
| my_steps_flows             | Array      | Array of Steps and when it's a Flow type it returns the child Flow (my_child_flow) and its Steps (my_steps).                                                                               |
| current_version            | Integer    | Usable version that will be used when trying to create a Case.                                                                                                                             |



**Without display_type**
```json
{
  "flow": {
    "list_versions": [
      {
        "created_at": "2015-03-04T00:17:01.471-03:00",
        "my_resolution_states": [],
        "resolution_states": [
          {
            "list_versions": null,
            "created_at": "2015-03-04T02:08:10.302-03:00",
            "updated_at": "2015-03-04T02:08:10.302-03:00",
            "version_id": null,
            "active": true,
            "default": true,
            "title": "Resolução 1",
            "id": 1
          }
        ],
        "steps_id": [
          "6",
          "5",
          "4"
        ],
        "steps_versions": {
          "6": 7,
          "5": 6,
          "4": 4
        },
        "initial": false,
        "description": null,
        "title": "Fluxo Inicial",
        "id": 3,
        "resolution_states_versions": {},
        "status": "pending",
        "draft": false,
        "total_cases": 0,
        "version_id": 8,
        "created_by_id": 1,
        "updated_by_id": 1,
        "updated_at": "2015-03-04T00:52:08.985-03:00"
      }
    ],
    "created_at": "2015-03-04T00:17:01.471-03:00",
    "my_resolution_states": [
      {
        "list_versions": null,
        "created_at": "2015-03-04T02:08:10.302-03:00",
        "updated_at": "2015-03-04T02:08:10.302-03:00",
        "version_id": null,
        "active": true,
        "default": true,
        "title": "Resolução 1",
        "id": 1
      }
    ],
    "resolution_states": [
      {
        "list_versions": null,
        "created_at": "2015-03-04T02:08:10.302-03:00",
        "updated_at": "2015-03-04T02:08:10.302-03:00",
        "version_id": null,
        "active": true,
        "default": true,
        "title": "Resolução 1",
        "id": 1
      }
    ],
    "steps_id": [
      "6",
      "5",
      "4"
    ],
    "steps_versions": {
      "6": 7,
      "5": 6,
      "4": 4
    },
    "initial": false,
    "description": null,
    "title": "Fluxo Inicial",
    "id": 3,
    "resolution_states_versions": {
      "1": null
    },
    "status": "active",
    "draft": true,
    "total_cases": 0,
    "version_id": null,
    "created_by_id": 1,
    "updated_by_id": 1,
    "updated_at": "2015-03-04T02:08:10.320-03:00"
  }
}
```

**With display_type=full**
```json
{
  "flow": {
    "list_versions": [
      {
        "created_at": "2015-03-04T00:17:01.471-03:00",
        "updated_at": "2015-03-04T00:52:08.985-03:00",
        "updated_by": {
          "google_plus_user_id": null,
          "twitter_user_id": null,
          "document": "67392343700",
          "phone": "11912231545",
          "email": "euricovidal@gmail.com",
          "groups_names": [
            "Administradores"
          ],
          "permissions": {
            "flow_can_delete_own_cases": [],
            "flow_can_delete_all_cases": [],
            "create_reports_from_panel": true,
            "updated_at": "2015-03-03T10:45:07.465-03:00",
            "created_at": "2015-03-03T10:45:07.461-03:00",
            "view_categories": false,
            "edit_reports": true,
            "edit_inventory_items": true,
            "delete_reports": false,
            "delete_inventory_items": false,
            "manage_config": true,
            "manage_inventory_formulas": true,
            "manage_reports": true,
            "id": 2,
            "group_id": 2,
            "manage_flows": true,
            "manage_users": true,
            "manage_inventory_categories": true,
            "manage_inventory_items": true,
            "manage_groups": true,
            "manage_reports_categories": true,
            "view_sections": false,
            "panel_access": true,
            "groups_can_edit": [],
            "groups_can_view": [],
            "reports_categories_can_edit": [],
            "reports_categories_can_view": [],
            "inventory_categories_can_edit": [],
            "inventory_categories_can_view": [],
            "inventory_sections_can_view": [],
            "inventory_sections_can_edit": [],
            "inventory_fields_can_edit": [],
            "inventory_fields_can_view": [],
            "flow_can_view_all_steps": [],
            "flow_can_execute_all_steps": [],
            "can_view_step": [],
            "can_execute_step": []
          },
          "groups": [
            {
              "permissions": {
                "flow_can_delete_own_cases": [],
                "flow_can_delete_all_cases": [],
                "create_reports_from_panel": true,
                "updated_at": "2015-03-03T10:45:07.465-03:00",
                "created_at": "2015-03-03T10:45:07.461-03:00",
                "view_categories": false,
                "edit_reports": true,
                "edit_inventory_items": true,
                "delete_reports": false,
                "delete_inventory_items": false,
                "manage_config": true,
                "manage_inventory_formulas": true,
                "manage_reports": true,
                "id": 2,
                "group_id": 2,
                "manage_flows": true,
                "manage_users": true,
                "manage_inventory_categories": true,
                "manage_inventory_items": true,
                "manage_groups": true,
                "manage_reports_categories": true,
                "view_sections": false,
                "panel_access": true,
                "groups_can_edit": [],
                "groups_can_view": [],
                "reports_categories_can_edit": [],
                "reports_categories_can_view": [],
                "inventory_categories_can_edit": [],
                "inventory_categories_can_view": [],
                "inventory_sections_can_view": [],
                "inventory_sections_can_edit": [],
                "inventory_fields_can_edit": [],
                "inventory_fields_can_view": [],
                "flow_can_view_all_steps": [],
                "flow_can_execute_all_steps": [],
                "can_view_step": [],
                "can_execute_step": []
              },
              "name": "Administradores",
              "id": 2
            }
          ],
          "name": "Hellen Armstrong Sr.",
          "id": 1,
          "address": "430 Danika Parkways",
          "address_additional": "Suite 386",
          "postal_code": "04005000",
          "district": "Lake Elsafort",
          "device_token": "445dcfb912fade983885d17f9aa42448",
          "device_type": "ios",
          "created_at": "2015-03-03T10:45:08.037-03:00",
          "facebook_user_id": null
        },
        "created_by": {
          "google_plus_user_id": null,
          "twitter_user_id": null,
          "document": "67392343700",
          "phone": "11912231545",
          "email": "euricovidal@gmail.com",
          "groups_names": [
            "Administradores"
          ],
          "permissions": {
            "flow_can_delete_own_cases": [],
            "flow_can_delete_all_cases": [],
            "create_reports_from_panel": true,
            "updated_at": "2015-03-03T10:45:07.465-03:00",
            "created_at": "2015-03-03T10:45:07.461-03:00",
            "view_categories": false,
            "edit_reports": true,
            "edit_inventory_items": true,
            "delete_reports": false,
            "delete_inventory_items": false,
            "manage_config": true,
            "manage_inventory_formulas": true,
            "manage_reports": true,
            "id": 2,
            "group_id": 2,
            "manage_flows": true,
            "manage_users": true,
            "manage_inventory_categories": true,
            "manage_inventory_items": true,
            "manage_groups": true,
            "manage_reports_categories": true,
            "view_sections": false,
            "panel_access": true,
            "groups_can_edit": [],
            "groups_can_view": [],
            "reports_categories_can_edit": [],
            "reports_categories_can_view": [],
            "inventory_categories_can_edit": [],
            "inventory_categories_can_view": [],
            "inventory_sections_can_view": [],
            "inventory_sections_can_edit": [],
            "inventory_fields_can_edit": [],
            "inventory_fields_can_view": [],
            "flow_can_view_all_steps": [],
            "flow_can_execute_all_steps": [],
            "can_view_step": [],
            "can_execute_step": []
          },
          "groups": [
            {
              "permissions": {
                "flow_can_delete_own_cases": [],
                "flow_can_delete_all_cases": [],
                "create_reports_from_panel": true,
                "updated_at": "2015-03-03T10:45:07.465-03:00",
                "created_at": "2015-03-03T10:45:07.461-03:00",
                "view_categories": false,
                "edit_reports": true,
                "edit_inventory_items": true,
                "delete_reports": false,
                "delete_inventory_items": false,
                "manage_config": true,
                "manage_inventory_formulas": true,
                "manage_reports": true,
                "id": 2,
                "group_id": 2,
                "manage_flows": true,
                "manage_users": true,
                "manage_inventory_categories": true,
                "manage_inventory_items": true,
                "manage_groups": true,
                "manage_reports_categories": true,
                "view_sections": false,
                "panel_access": true,
                "groups_can_edit": [],
                "groups_can_view": [],
                "reports_categories_can_edit": [],
                "reports_categories_can_view": [],
                "inventory_categories_can_edit": [],
                "inventory_categories_can_view": [],
                "inventory_sections_can_view": [],
                "inventory_sections_can_edit": [],
                "inventory_fields_can_edit": [],
                "inventory_fields_can_view": [],
                "flow_can_view_all_steps": [],
                "flow_can_execute_all_steps": [],
                "can_view_step": [],
                "can_execute_step": []
              },
              "name": "Administradores",
              "id": 2
            }
          ],
          "name": "Hellen Armstrong Sr.",
          "id": 1,
          "address": "430 Danika Parkways",
          "address_additional": "Suite 386",
          "postal_code": "04005000",
          "district": "Lake Elsafort",
          "device_token": "445dcfb912fade983885d17f9aa42448",
          "device_type": "ios",
          "created_at": "2015-03-03T10:45:08.037-03:00",
          "facebook_user_id": null
        },
        "steps_versions": {
          "6": 7,
          "5": 6,
          "4": 4
        },
        "my_steps_flows": [
          {
            "my_child_flow": {
              "my_steps": [],
              "steps_versions": {},
              "resolution_states_versions": {},
              "draft": false,
              "current_version": null,
              "step_id": null,
              "status": "pending",
              "id": 4,
              "title": "Fluxo Filho",
              "description": null,
              "created_by_id": 1,
              "updated_by_id": 1,
              "initial": false,
              "created_at": "2015-03-04T00:30:40.425-03:00",
              "updated_at": "2015-03-04T00:31:03.225-03:00"
            },
            "triggers_versions": {},
            "fields_versions": {},
            "user_id": 1,
            "draft": false,
            "conduction_mode_open": true,
            "child_flow_version": null,
            "child_flow_id": 4,
            "id": 6,
            "title": "Etapa 3",
            "description": null,
            "step_type": "flow",
            "flow_id": 3,
            "created_at": "2015-03-04T00:31:37.531-03:00",
            "updated_at": "2015-03-04T00:51:47.252-03:00",
            "active": true
          },
          {
            "triggers_versions": {},
            "fields_versions": {
              "3": 5
            },
            "user_id": 1,
            "draft": false,
            "conduction_mode_open": true,
            "child_flow_version": null,
            "child_flow_id": null,
            "id": 5,
            "title": "Etapa 2",
            "description": null,
            "step_type": "form",
            "flow_id": 3,
            "created_at": "2015-03-04T00:30:06.214-03:00",
            "updated_at": "2015-03-04T00:51:47.232-03:00",
            "active": true
          },
          {
            "triggers_versions": {},
            "fields_versions": {
              "2": 3
            },
            "user_id": 1,
            "draft": false,
            "conduction_mode_open": true,
            "child_flow_version": null,
            "child_flow_id": null,
            "id": 4,
            "title": "Etapa 1",
            "description": null,
            "step_type": "form",
            "flow_id": 3,
            "created_at": "2015-03-04T00:24:26.529-03:00",
            "updated_at": "2015-03-04T00:51:47.210-03:00",
            "active": true
          }
        ],
        "my_steps": [
          {
            "triggers_versions": {},
            "fields_versions": {},
            "user_id": 1,
            "draft": false,
            "conduction_mode_open": true,
            "child_flow_version": null,
            "child_flow_id": 4,
            "id": 6,
            "title": "Etapa 3",
            "description": null,
            "step_type": "flow",
            "flow_id": 3,
            "created_at": "2015-03-04T00:31:37.531-03:00",
            "updated_at": "2015-03-04T00:51:47.252-03:00",
            "active": true
          },
          {
            "triggers_versions": {},
            "fields_versions": {
              "3": 5
            },
            "user_id": 1,
            "draft": false,
            "conduction_mode_open": true,
            "child_flow_version": null,
            "child_flow_id": null,
            "id": 5,
            "title": "Etapa 2",
            "description": null,
            "step_type": "form",
            "flow_id": 3,
            "created_at": "2015-03-04T00:30:06.214-03:00",
            "updated_at": "2015-03-04T00:51:47.232-03:00",
            "active": true
          },
          {
            "triggers_versions": {},
            "fields_versions": {
              "2": 3
            },
            "user_id": 1,
            "draft": false,
            "conduction_mode_open": true,
            "child_flow_version": null,
            "child_flow_id": null,
            "id": 4,
            "title": "Etapa 1",
            "description": null,
            "step_type": "form",
            "flow_id": 3,
            "created_at": "2015-03-04T00:24:26.529-03:00",
            "updated_at": "2015-03-04T00:51:47.210-03:00",
            "active": true
          }
        ],
        "steps": [
          {
            "triggers_versions": {},
            "fields_versions": {
              "2": 3
            },
            "user_id": 1,
            "draft": false,
            "conduction_mode_open": true,
            "child_flow_version": null,
            "child_flow_id": null,
            "id": 4,
            "title": "Etapa 1",
            "description": null,
            "step_type": "form",
            "flow_id": 3,
            "created_at": "2015-03-04T00:24:26.529-03:00",
            "updated_at": "2015-03-04T00:51:47.210-03:00",
            "active": true
          },
          {
            "triggers_versions": {},
            "fields_versions": {
              "3": 5
            },
            "user_id": 1,
            "draft": false,
            "conduction_mode_open": true,
            "child_flow_version": null,
            "child_flow_id": null,
            "id": 5,
            "title": "Etapa 2",
            "description": null,
            "step_type": "form",
            "flow_id": 3,
            "created_at": "2015-03-04T00:30:06.214-03:00",
            "updated_at": "2015-03-04T00:51:47.232-03:00",
            "active": true
          },
          {
            "triggers_versions": {},
            "fields_versions": {},
            "user_id": 1,
            "draft": false,
            "conduction_mode_open": true,
            "child_flow_version": null,
            "child_flow_id": 4,
            "id": 6,
            "title": "Etapa 3",
            "description": null,
            "step_type": "flow",
            "flow_id": 3,
            "created_at": "2015-03-04T00:31:37.531-03:00",
            "updated_at": "2015-03-04T00:51:47.252-03:00",
            "active": true
          }
        ],
        "initial": false,
        "description": null,
        "title": "Fluxo Inicial",
        "id": 3,
        "resolution_states": [
          {
            "list_versions": null,
            "created_at": "2015-03-04T02:08:10.302-03:00",
            "updated_at": "2015-03-04T02:08:10.302-03:00",
            "version_id": null,
            "active": true,
            "default": true,
            "title": "Resolução 1",
            "id": 1
          }
        ],
        "my_resolution_states": [],
        "resolution_states_versions": {},
        "status": "pending",
        "draft": false,
        "total_cases": 0,
        "version_id": 8,
        "permissions": {
          "flow_can_delete_all_cases": [],
          "flow_can_delete_own_cases": [],
          "flow_can_execute_all_steps": [],
          "flow_can_view_all_steps": []
        }
      }
    ],
    "created_at": "2015-03-04T00:17:01.471-03:00",
    "updated_at": "2015-03-04T02:08:10.320-03:00",
    "updated_by": {
      "google_plus_user_id": null,
      "twitter_user_id": null,
      "document": "67392343700",
      "phone": "11912231545",
      "email": "euricovidal@gmail.com",
      "groups_names": [
        "Administradores"
      ],
      "permissions": {
        "flow_can_delete_own_cases": [],
        "flow_can_delete_all_cases": [],
        "create_reports_from_panel": true,
        "updated_at": "2015-03-03T10:45:07.465-03:00",
        "created_at": "2015-03-03T10:45:07.461-03:00",
        "view_categories": false,
        "edit_reports": true,
        "edit_inventory_items": true,
        "delete_reports": false,
        "delete_inventory_items": false,
        "manage_config": true,
        "manage_inventory_formulas": true,
        "manage_reports": true,
        "id": 2,
        "group_id": 2,
        "manage_flows": true,
        "manage_users": true,
        "manage_inventory_categories": true,
        "manage_inventory_items": true,
        "manage_groups": true,
        "manage_reports_categories": true,
        "view_sections": false,
        "panel_access": true,
        "groups_can_edit": [],
        "groups_can_view": [],
        "reports_categories_can_edit": [],
        "reports_categories_can_view": [],
        "inventory_categories_can_edit": [],
        "inventory_categories_can_view": [],
        "inventory_sections_can_view": [],
        "inventory_sections_can_edit": [],
        "inventory_fields_can_edit": [],
        "inventory_fields_can_view": [],
        "flow_can_view_all_steps": [],
        "flow_can_execute_all_steps": [],
        "can_view_step": [],
        "can_execute_step": []
      },
      "groups": [
        {
          "permissions": {
            "flow_can_delete_own_cases": [],
            "flow_can_delete_all_cases": [],
            "create_reports_from_panel": true,
            "updated_at": "2015-03-03T10:45:07.465-03:00",
            "created_at": "2015-03-03T10:45:07.461-03:00",
            "view_categories": false,
            "edit_reports": true,
            "edit_inventory_items": true,
            "delete_reports": false,
            "delete_inventory_items": false,
            "manage_config": true,
            "manage_inventory_formulas": true,
            "manage_reports": true,
            "id": 2,
            "group_id": 2,
            "manage_flows": true,
            "manage_users": true,
            "manage_inventory_categories": true,
            "manage_inventory_items": true,
            "manage_groups": true,
            "manage_reports_categories": true,
            "view_sections": false,
            "panel_access": true,
            "groups_can_edit": [],
            "groups_can_view": [],
            "reports_categories_can_edit": [],
            "reports_categories_can_view": [],
            "inventory_categories_can_edit": [],
            "inventory_categories_can_view": [],
            "inventory_sections_can_view": [],
            "inventory_sections_can_edit": [],
            "inventory_fields_can_edit": [],
            "inventory_fields_can_view": [],
            "flow_can_view_all_steps": [],
            "flow_can_execute_all_steps": [],
            "can_view_step": [],
            "can_execute_step": []
          },
          "name": "Administradores",
          "id": 2
        }
      ],
      "name": "Hellen Armstrong Sr.",
      "id": 1,
      "address": "430 Danika Parkways",
      "address_additional": "Suite 386",
      "postal_code": "04005000",
      "district": "Lake Elsafort",
      "device_token": "445dcfb912fade983885d17f9aa42448",
      "device_type": "ios",
      "created_at": "2015-03-03T10:45:08.037-03:00",
      "facebook_user_id": null
    },
    "created_by": {
      "google_plus_user_id": null,
      "twitter_user_id": null,
      "document": "67392343700",
      "phone": "11912231545",
      "email": "euricovidal@gmail.com",
      "groups_names": [
        "Administradores"
      ],
      "permissions": {
        "flow_can_delete_own_cases": [],
        "flow_can_delete_all_cases": [],
        "create_reports_from_panel": true,
        "updated_at": "2015-03-03T10:45:07.465-03:00",
        "created_at": "2015-03-03T10:45:07.461-03:00",
        "view_categories": false,
        "edit_reports": true,
        "edit_inventory_items": true,
        "delete_reports": false,
        "delete_inventory_items": false,
        "manage_config": true,
        "manage_inventory_formulas": true,
        "manage_reports": true,
        "id": 2,
        "group_id": 2,
        "manage_flows": true,
        "manage_users": true,
        "manage_inventory_categories": true,
        "manage_inventory_items": true,
        "manage_groups": true,
        "manage_reports_categories": true,
        "view_sections": false,
        "panel_access": true,
        "groups_can_edit": [],
        "groups_can_view": [],
        "reports_categories_can_edit": [],
        "reports_categories_can_view": [],
        "inventory_categories_can_edit": [],
        "inventory_categories_can_view": [],
        "inventory_sections_can_view": [],
        "inventory_sections_can_edit": [],
        "inventory_fields_can_edit": [],
        "inventory_fields_can_view": [],
        "flow_can_view_all_steps": [],
        "flow_can_execute_all_steps": [],
        "can_view_step": [],
        "can_execute_step": []
      },
      "groups": [
        {
          "permissions": {
            "flow_can_delete_own_cases": [],
            "flow_can_delete_all_cases": [],
            "create_reports_from_panel": true,
            "updated_at": "2015-03-03T10:45:07.465-03:00",
            "created_at": "2015-03-03T10:45:07.461-03:00",
            "view_categories": false,
            "edit_reports": true,
            "edit_inventory_items": true,
            "delete_reports": false,
            "delete_inventory_items": false,
            "manage_config": true,
            "manage_inventory_formulas": true,
            "manage_reports": true,
            "id": 2,
            "group_id": 2,
            "manage_flows": true,
            "manage_users": true,
            "manage_inventory_categories": true,
            "manage_inventory_items": true,
            "manage_groups": true,
            "manage_reports_categories": true,
            "view_sections": false,
            "panel_access": true,
            "groups_can_edit": [],
            "groups_can_view": [],
            "reports_categories_can_edit": [],
            "reports_categories_can_view": [],
            "inventory_categories_can_edit": [],
            "inventory_categories_can_view": [],
            "inventory_sections_can_view": [],
            "inventory_sections_can_edit": [],
            "inventory_fields_can_edit": [],
            "inventory_fields_can_view": [],
            "flow_can_view_all_steps": [],
            "flow_can_execute_all_steps": [],
            "can_view_step": [],
            "can_execute_step": []
          },
          "name": "Administradores",
          "id": 2
        }
      ],
      "name": "Hellen Armstrong Sr.",
      "id": 1,
      "address": "430 Danika Parkways",
      "address_additional": "Suite 386",
      "postal_code": "04005000",
      "district": "Lake Elsafort",
      "device_token": "445dcfb912fade983885d17f9aa42448",
      "device_type": "ios",
      "created_at": "2015-03-03T10:45:08.037-03:00",
      "facebook_user_id": null
    },
    "steps_versions": {
      "6": 7,
      "5": 6,
      "4": 4
    },
    "my_steps_flows": [
      {
        "my_child_flow": {
          "my_steps": [],
          "steps_versions": {},
          "resolution_states_versions": {},
          "draft": false,
          "current_version": null,
          "step_id": null,
          "status": "pending",
          "id": 4,
          "title": "Fluxo Filho",
          "description": null,
          "created_by_id": 1,
          "updated_by_id": 1,
          "initial": false,
          "created_at": "2015-03-04T00:30:40.425-03:00",
          "updated_at": "2015-03-04T00:31:03.225-03:00"
        },
        "triggers_versions": {},
        "fields_versions": {},
        "user_id": 1,
        "draft": false,
        "conduction_mode_open": true,
        "child_flow_version": null,
        "child_flow_id": 4,
        "id": 6,
        "title": "Etapa 3",
        "description": null,
        "step_type": "flow",
        "flow_id": 3,
        "created_at": "2015-03-04T00:31:37.531-03:00",
        "updated_at": "2015-03-04T00:51:47.252-03:00",
        "active": true
      },
      {
        "triggers_versions": {},
        "fields_versions": {
          "3": 5
        },
        "user_id": 1,
        "draft": false,
        "conduction_mode_open": true,
        "child_flow_version": null,
        "child_flow_id": null,
        "id": 5,
        "title": "Etapa 2",
        "description": null,
        "step_type": "form",
        "flow_id": 3,
        "created_at": "2015-03-04T00:30:06.214-03:00",
        "updated_at": "2015-03-04T00:51:47.232-03:00",
        "active": true
      },
      {
        "triggers_versions": {},
        "fields_versions": {
          "2": 3
        },
        "user_id": 1,
        "draft": false,
        "conduction_mode_open": true,
        "child_flow_version": null,
        "child_flow_id": null,
        "id": 4,
        "title": "Etapa 1",
        "description": null,
        "step_type": "form",
        "flow_id": 3,
        "created_at": "2015-03-04T00:24:26.529-03:00",
        "updated_at": "2015-03-04T00:51:47.210-03:00",
        "active": true
      }
    ],
    "my_steps": [
      {
        "triggers_versions": {},
        "fields_versions": {},
        "user_id": 1,
        "draft": false,
        "conduction_mode_open": true,
        "child_flow_version": null,
        "child_flow_id": 4,
        "id": 6,
        "title": "Etapa 3",
        "description": null,
        "step_type": "flow",
        "flow_id": 3,
        "created_at": "2015-03-04T00:31:37.531-03:00",
        "updated_at": "2015-03-04T00:51:47.252-03:00",
        "active": true
      },
      {
        "triggers_versions": {},
        "fields_versions": {
          "3": 5
        },
        "user_id": 1,
        "draft": false,
        "conduction_mode_open": true,
        "child_flow_version": null,
        "child_flow_id": null,
        "id": 5,
        "title": "Etapa 2",
        "description": null,
        "step_type": "form",
        "flow_id": 3,
        "created_at": "2015-03-04T00:30:06.214-03:00",
        "updated_at": "2015-03-04T00:51:47.232-03:00",
        "active": true
      },
      {
        "triggers_versions": {},
        "fields_versions": {
          "2": 3
        },
        "user_id": 1,
        "draft": false,
        "conduction_mode_open": true,
        "child_flow_version": null,
        "child_flow_id": null,
        "id": 4,
        "title": "Etapa 1",
        "description": null,
        "step_type": "form",
        "flow_id": 3,
        "created_at": "2015-03-04T00:24:26.529-03:00",
        "updated_at": "2015-03-04T00:51:47.210-03:00",
        "active": true
      }
    ],
    "steps": [
      {
        "triggers_versions": {},
        "fields_versions": {
          "2": 3
        },
        "user_id": 1,
        "draft": false,
        "conduction_mode_open": true,
        "child_flow_version": null,
        "child_flow_id": null,
        "id": 4,
        "title": "Etapa 1",
        "description": null,
        "step_type": "form",
        "flow_id": 3,
        "created_at": "2015-03-04T00:24:26.529-03:00",
        "updated_at": "2015-03-04T00:51:47.210-03:00",
        "active": true
      },
      {
        "triggers_versions": {},
        "fields_versions": {
          "3": 5
        },
        "user_id": 1,
        "draft": false,
        "conduction_mode_open": true,
        "child_flow_version": null,
        "child_flow_id": null,
        "id": 5,
        "title": "Etapa 2",
        "description": null,
        "step_type": "form",
        "flow_id": 3,
        "created_at": "2015-03-04T00:30:06.214-03:00",
        "updated_at": "2015-03-04T00:51:47.232-03:00",
        "active": true
      },
      {
        "triggers_versions": {},
        "fields_versions": {},
        "user_id": 1,
        "draft": false,
        "conduction_mode_open": true,
        "child_flow_version": null,
        "child_flow_id": 4,
        "id": 6,
        "title": "Etapa 3",
        "description": null,
        "step_type": "flow",
        "flow_id": 3,
        "created_at": "2015-03-04T00:31:37.531-03:00",
        "updated_at": "2015-03-04T00:51:47.252-03:00",
        "active": true
      }
    ],
    "initial": false,
    "description": null,
    "title": "Fluxo Inicial",
    "id": 3,
    "resolution_states": [
      {
        "list_versions": null,
        "created_at": "2015-03-04T02:08:10.302-03:00",
        "updated_at": "2015-03-04T02:08:10.302-03:00",
        "version_id": null,
        "active": true,
        "default": true,
        "title": "Resolução 1",
        "id": 1
      }
    ],
    "my_resolution_states": [
      {
        "list_versions": null,
        "created_at": "2015-03-04T02:08:10.302-03:00",
        "updated_at": "2015-03-04T02:08:10.302-03:00",
        "version_id": null,
        "active": true,
        "default": true,
        "title": "Resolução 1",
        "id": 1
      }
    ],
    "resolution_states_versions": {
      "1": null
    },
    "status": "active",
    "draft": true,
    "total_cases": 0,
    "version_id": null,
    "permissions": {
      "flow_can_delete_all_cases": [],
      "flow_can_delete_own_cases": [],
      "flow_can_execute_all_steps": [],
      "flow_can_view_all_steps": []
    }
  }
}
```

___

### Publish Flow <a name="publish"></a>

When the Flow has changes, its draft parameter is equal to true (draft=true). Thus, it is necessary to publish the Flow in order to create a version. If the Flow does not have Cases, its latest version will be updated with the changes. If there are any Cases for the Flow, a new version will be created.

Endpoint: `/flows/:id/publish`

Method: post

#### Input Parameters

#### HTTP status

| Code | Description              |
|------|--------------------------|
| 401  | Unauthorized access.     |
| 404  | Flow does not exist.     |
| 201  | Success message.         |


#### Example

##### Response
```
Status: 201
Content-Type: application/json
```

```json
{
  "message": "Fluxo publicado com sucesso"
}
```

___

### Change Current Version <a name="change_version"></a>

Endpoint: `/flows/:id/version`

Method: put

#### Input Parameters

| Name          | Type    | Required    | Description                                  |
|---------------|---------|-------------|----------------------------------------------|
| new_version   | Integer | Yes         | Flow version, to change the current version. |

#### HTTP status

| Code | Description              |
|------|--------------------------|
| 400  | Invalid version.         |
| 401  | Unauthorized access.     |
| 404  | Flow does not exist.     |
| 200  | Success message.         |


#### Example

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Versão do Fluxo atualizado para 2"
}
```

___

### Add Permission <a name="permission_add"></a>

Endpoint: `/flows/:id/permissions`

Method: put

#### Input Parameters

| Name            | Type    | Required    | Description                            |
|-----------------|---------|-------------|----------------------------------------|
| group_ids       | Array   | Yes         | Array of Group IDs to be  changed.     |
| permission_type | String  | Yes         | Permission type to be added.           |

#### Permissions types

| Permission                 | Parameter    | Description                                                                |
|----------------------------|--------------|----------------------------------------------------------------------------|
| flow_can_execute_all_steps | Flow ID      | Can visualize and run all children Steps of the Flow (direct children).    |
| flow_can_view_all_steps    | Flow ID      | Can visualize all children Steps of the Flow (direct children).            |
| flow_can_delete_own_cases  | Flow ID      | Can delete/restore your own Cases (also required visualization permission) |
| flow_can_delete_all_cases  | Flow ID      | Can delete/restore any Cases (visualization permission is also required)   |

#### HTTP status

| Code | Description                |
|------|----------------------------|
| 400  | Permission does not exist. |
| 401  | Unauthorized access.       |
| 404  | Does not exist.            |
| 200  | Successfully updated.      |


#### Example

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  message: "Permissões atualizadas com sucesso"
}
```

___

### Remove Permission <a name="permission_rem"></a>

Endpoint: `/flows/:id/permissions`

Method: delete

#### Input Parameters

| Name            | Type    | Required    | Description                            |
|-----------------|---------|-------------|----------------------------------------|
| group_ids       | Array   | Yes         | Array of Group IDs to be changed.      |
| permission_type | String  | Yes         | Permission type to be removed.         |

#### Permissions types

| Permission                 | Parameter    | Description                                                                |
|----------------------------|--------------|----------------------------------------------------------------------------|
| flow_can_execute_all_steps | Flow ID      | Can visualize and run all children Steps of the Flow (direct children).    |
| flow_can_view_all_steps    | Flow ID      | Can visualize all children Steps of the Flow (direct children).            |
| flow_can_delete_own_cases  | Flow ID      | Can delete/restore your own Cases (also required visualization permission) |
| flow_can_delete_all_cases  | Flow ID      | Can delete/restore any Case (visualization permission is also required)    |


#### HTTP status

| Code | Description                |
|------|----------------------------|
| 400  | Permission does not exist. |
| 401  | Unauthorized access.       |
| 404  | Does not exist.            |
| 200  | Successfully updated.      |


#### Example

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  message: "Permissões atualizadas com sucesso"
}
```
