# ZUP-API Documentation - Flows - Steps

## Protocol

The adopted protocol is REST, and a JSON is received as the input parameter. It is necessary to perform an authentication request and to use a TOKEN in the requests to this Endpoint. The creation of a Flow is also required for proper usage of this endpoint.

Endpoint Staging: `http://staging.zup.sapience.io/flows/:flow_id/steps`

Example of how to carry out a request using cURL tool:

```bash
curl -X POST --data-binary @steps-data.json -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows/:flow_id/steps
```
Or
```bash
curl -X POST --data-binary '{"campo":"valor"}' -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows/:flow_id/steps
```

## Services

### Content

* [List](#list)
* [Create](#create)
* [Update](#update)
* [Display](#show)
* [Delete](#delete)
* [Reset Order](#order)
* [Permissions](#permission)

___

### Display <a name="show"></a>

Endpoint: `/flows/:flow_id/steps/:id`

Method: get

#### Input parameters

| Name          | Type    | Required   | Description                                            |
|---------------|---------|------------|--------------------------------------------------------|
| display_type  | String  | No         | To return all the values use the parameter as 'full'.  |

#### HTTP status

| Code | Description           |
|------|-----------------------|
| 401  | Unauthorized access.  |
| 404  | Not found.            |
| 200  | Display Step.         |


#### Example

##### Request
```
?display_type=full
```

##### Response
```
Status: 200
Content-Type: application/json
```

###### FieldObject
| Name                  | Type       | Description                                                                                    		   |
|-----------------------|------------|---------------------------------------------------------------------------------------------------------|
| id                    | Integer    | Object ID.                                                                                     		   |
| list_versions         | Array      | Array with all versions of the object.                                                          		   |
| created_at            | DateTime   | Date and time of object creation.                                                               		   |
| updated_at            | DateTime   | Date and time of object's last update.                                                          		   |
| title                 | String     | Object title.                                                                                   		   |
| active                | Boolean    | Whether the object is activated.                                                                		   |
| conduction_mode_open  | Boolean    | Whether the Step conduction mode is Open.                                                       		   |
| step_type             | String     | Step type (form or flow)                                                                        		   |
| version_id            | Integer    | Object version ID.                                                                              		   |
| permissions           | Object     | Permission list (the key represents the permission and the value is an array of group IDs).     		   |
| child_flow            | Object     | If the type of the Step is "flow" there must be a child flow (current)                                  |
| my_child_flow         | Object     | If the type of the Step is "flow" there must be have a child flow (corresponding to the Step's version) |
| fields                | Array      | If the type of the Step is "form" there must be Fields (current)                                        |
| my_fields             | Array      | If the type of the Step is "form" there must be Fields (corresponding to the Step's version)            |


**Without display_type**
```json
{
  "step": {
    "list_versions": null,
    "created_at": "2015-03-03T10:53:39.760-03:00",
    "updated_at": "2015-03-03T13:30:29.090-03:00",
    "id": 1,
    "title": "Etapa 1",
    "conduction_mode_open": true,
    "step_type": "form",
    "child_flow_id": null,
    "fields_id": [
      1
    ],
    "active": true,
    "version_id": null
  }
}
```

**With display_type=full**
```json
{
  "step": {
    "list_versions": null,
    "created_at": "2015-03-03T10:53:39.760-03:00",
    "updated_at": "2015-03-03T13:30:29.090-03:00",
    "permissions": {
      "can_execute_step": [],
      "can_view_step": []
    },
    "version_id": null,
    "active": true,
    "id": 1,
    "title": "Etapa 1",
    "conduction_mode_open": true,
    "step_type": "form",
    "child_flow": null,
    "my_child_flow": null,
    "fields": [
      {
        "draft": true,
        "step_id": 1,
        "active": true,
        "origin_field_id": null,
        "category_report_id": null,
        "category_inventory_id": null,
        "field_type": "text",
        "title": "Campo 1",
        "id": 1,
        "created_at": "2015-03-03T13:30:29.082-03:00",
        "updated_at": "2015-03-03T13:30:29.082-03:00",
        "multiple": false,
        "filter": null,
        "requirements": {
          "presence": "true"
        },
        "values": null,
        "user_id": 1,
        "origin_field_version": null
      }
    ],
    "my_fields": [
      {
        "draft": true,
        "step_id": 1,
        "active": true,
        "origin_field_id": null,
        "category_report_id": null,
        "category_inventory_id": null,
        "field_type": "text",
        "title": "Campo 1",
        "id": 1,
        "created_at": "2015-03-03T13:30:29.082-03:00",
        "updated_at": "2015-03-03T13:30:29.082-03:00",
        "multiple": false,
        "filter": null,
        "requirements": {
          "presence": "true"
        },
        "values": null,
        "user_id": 1,
        "origin_field_version": null
      }
    ]
  }
}
```
___

### Listing Steps <a name="list"></a>

Endpoint: `/flows/:flow_id/steps`

Method: get

#### Input parameters

| Name          | Type    | Required   | Description                                            |
|---------------|---------|------------|--------------------------------------------------------|
| display_type  | String  | No         | To return all the values use the parameter as 'full'.  |

#### HTTP status

| Code | Description                                |
|------|--------------------------------------------|
| 401  | Unauthorized access.                       |
| 200  | Listing is displayed (with zero or more).  |


#### Example

##### Request
```
?display_type=full
```

##### Response
```
Status: 200
Content-Type: application/json
```

| Name     | Type    | Description                                   |
|----------|---------|-----------------------------------------------|
| steps    | Array   | Array of Steps (see StepObject get /step/:id) |

**Without display_type**
```json
{
  "steps": [
    {
      "list_versions": null,
      "created_at": "2015-03-03T10:53:39.760-03:00",
      "updated_at": "2015-03-03T13:30:29.090-03:00",
      "id": 1,
      "title": "Etapa 1",
      "conduction_mode_open": true,
      "step_type": "form",
      "child_flow_id": null,
      "fields_id": [
        1
      ],
      "active": true,
      "version_id": null
    },
    {
      "list_versions": null,
      "created_at": "2015-03-03T14:06:58.394-03:00",
      "updated_at": "2015-03-03T14:06:58.394-03:00",
      "id": 2,
      "title": "Etaoa 2",
      "conduction_mode_open": true,
      "step_type": "form",
      "child_flow_id": null,
      "fields_id": [],
      "active": true,
      "version_id": null
    },
    {
      "list_versions": null,
      "created_at": "2015-03-03T14:21:38.430-03:00",
      "updated_at": "2015-03-03T14:21:38.430-03:00",
      "id": 3,
      "title": "Etapa 3",
      "conduction_mode_open": true,
      "step_type": "flow",
      "child_flow_id": 2,
      "fields_id": [],
      "active": true,
      "version_id": null
    }
  ]
}
```

**With display_type=full**
```json
{
  "steps": [
    {
      "list_versions": null,
      "created_at": "2015-03-03T10:53:39.760-03:00",
      "updated_at": "2015-03-03T13:30:29.090-03:00",
      "permissions": {
        "can_execute_step": [],
        "can_view_step": []
      },
      "version_id": null,
      "active": true,
      "id": 1,
      "title": "Etapa 1",
      "conduction_mode_open": true,
      "step_type": "form",
      "child_flow": null,
      "my_child_flow": null,
      "fields": [
        {
          "draft": true,
          "step_id": 1,
          "active": true,
          "origin_field_id": null,
          "category_report_id": null,
          "category_inventory_id": null,
          "field_type": "text",
          "title": "Campo 1",
          "id": 1,
          "created_at": "2015-03-03T13:30:29.082-03:00",
          "updated_at": "2015-03-03T13:30:29.082-03:00",
          "multiple": false,
          "filter": null,
          "requirements": {
            "presence": "true"
          },
          "values": null,
          "user_id": 1,
          "origin_field_version": null
        }
      ],
      "my_fields": [
        {
          "draft": true,
          "step_id": 1,
          "active": true,
          "origin_field_id": null,
          "category_report_id": null,
          "category_inventory_id": null,
          "field_type": "text",
          "title": "Campo 1",
          "id": 1,
          "created_at": "2015-03-03T13:30:29.082-03:00",
          "updated_at": "2015-03-03T13:30:29.082-03:00",
          "multiple": false,
          "filter": null,
          "requirements": {
            "presence": "true"
          },
          "values": null,
          "user_id": 1,
          "origin_field_version": null
        }
      ]
    },
    {
      "list_versions": null,
      "created_at": "2015-03-03T14:06:58.394-03:00",
      "updated_at": "2015-03-03T14:06:58.394-03:00",
      "permissions": {
        "can_execute_step": [],
        "can_view_step": []
      },
      "version_id": null,
      "active": true,
      "id": 2,
      "title": "Etaoa 2",
      "conduction_mode_open": true,
      "step_type": "form",
      "child_flow": null,
      "my_child_flow": null,
      "fields": [],
      "my_fields": []
    },
    {
      "list_versions": null,
      "created_at": "2015-03-03T14:21:38.430-03:00",
      "updated_at": "2015-03-03T14:21:38.430-03:00",
      "permissions": {
        "can_execute_step": [],
        "can_view_step": []
      },
      "version_id": null,
      "active": true,
      "id": 3,
      "title": "Etapa 3",
      "conduction_mode_open": true,
      "step_type": "flow",
      "child_flow": {
        "list_versions": [
          {
            "created_at": "2015-03-03T14:20:55.690-03:00",
            "updated_at": "2015-03-03T14:21:07.015-03:00",
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
            "steps_versions": {},
            "my_steps_flows": [],
            "my_steps": [],
            "steps": [],
            "initial": false,
            "description": null,
            "title": "Fluxo Filho",
            "id": 2,
            "resolution_states": [],
            "my_resolution_states": [],
            "resolution_states_versions": {},
            "status": "pending",
            "draft": false,
            "total_cases": 0,
            "version_id": 1,
            "permissions": {
              "flow_can_delete_all_cases": [],
              "flow_can_delete_own_cases": [],
              "flow_can_execute_all_steps": [],
              "flow_can_view_all_steps": []
            }
          }
        ],
        "created_at": "2015-03-03T14:20:55.690-03:00",
        "updated_at": "2015-03-03T14:21:07.015-03:00",
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
        "steps_versions": {},
        "my_steps_flows": [],
        "my_steps": [],
        "steps": [],
        "initial": false,
        "description": null,
        "title": "Fluxo Filho",
        "id": 2,
        "resolution_states": [],
        "my_resolution_states": [],
        "resolution_states_versions": {},
        "status": "pending",
        "draft": false,
        "total_cases": 0,
        "version_id": null,
        "permissions": {
          "flow_can_delete_all_cases": [],
          "flow_can_delete_own_cases": [],
          "flow_can_execute_all_steps": [],
          "flow_can_view_all_steps": []
        }
      },
      "my_child_flow": {
        "list_versions": [
          {
            "created_at": "2015-03-03T14:20:55.690-03:00",
            "updated_at": "2015-03-03T14:21:07.015-03:00",
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
            "steps_versions": {},
            "my_steps_flows": [],
            "my_steps": [],
            "steps": [],
            "initial": false,
            "description": null,
            "title": "Fluxo Filho",
            "id": 2,
            "resolution_states": [],
            "my_resolution_states": [],
            "resolution_states_versions": {},
            "status": "pending",
            "draft": false,
            "total_cases": 0,
            "version_id": 1,
            "permissions": {
              "flow_can_delete_all_cases": [],
              "flow_can_delete_own_cases": [],
              "flow_can_execute_all_steps": [],
              "flow_can_view_all_steps": []
            }
          }
        ],
        "created_at": "2015-03-03T14:20:55.690-03:00",
        "updated_at": "2015-03-03T14:21:07.015-03:00",
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
        "steps_versions": {},
        "my_steps_flows": [],
        "my_steps": [],
        "steps": [],
        "initial": false,
        "description": null,
        "title": "Fluxo Filho",
        "id": 2,
        "resolution_states": [],
        "my_resolution_states": [],
        "resolution_states_versions": {},
        "status": "pending",
        "draft": false,
        "total_cases": 0,
        "version_id": null,
        "permissions": {
          "flow_can_delete_all_cases": [],
          "flow_can_delete_own_cases": [],
          "flow_can_execute_all_steps": [],
          "flow_can_view_all_steps": []
        }
      },
      "fields": [],
      "my_fields": []
    }
  ]
}
```
___

### Resetting Steps Ordering <a name="order"></a>

Endpoint: `/flows/:flow_id/steps`

Method: put

#### Input Parameters

| Name | Type  | Required    | Description                              |
|------|-------|-------------|------------------------------------------|
| ids  | Array | Yes         | Array of Step ids in the desired order.  |

#### HTTP status

| Code | Description                  |
|------|------------------------------|
| 400  | Invalid parameters.          |
| 401  | Unauthorized access.         |
| 200  | Displays success message.    |


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
  "message": "Ordem das Etadas atualizada com sucesso"
}
```
___

### Creating a Step <a name="create"></a>

When registering a Step of Flow Type, the child Flow must be published.

Endpoint: `/flows/:flow_id/steps`

Method: post

#### Input Parameters

| Name                  | Type    | Required   | Description                                                             |
|-----------------------|---------|------------|-------------------------------------------------------------------------|
| title                 | String  | Yes        | Step title. (up to 100 characters)                                      |
| step_type             | String  | Yes        | Step type. ('flow' or 'form')                                           |
| conduction_modeo_open | Boolean | No         | Step conduction mode. (by default it's Open/true)                       |
| child_flow_id         | Integer | No         | If step_type is flow it is necessary to inform the child Flow's id      |
| child_flow_version    | Integer | No         | If step_type is flow it is necessary to inform the child Flow's version |

#### HTTP status

| Code | Description               |
|------|---------------------------|
| 400  | Invalid parameters.       |
| 401  | Unauthorized access.      |
| 200  | If successfully created.  |


#### Example

##### Request
```json
{
  "title": "Título da Etapa",
  "step_type": "flow",
  "conduction_mode_open": false,
  "child_flow_id": 1,
  "child_flow_version": 1,
}
```

##### Response
```
Status: 201
Content-Type: application/json
```

| Name   | Type    | Description                          |
|--------|---------|--------------------------------------|
| step   | Object  | Step (see StepObject get /steps/:id) |

```json
{
  "step": {
    "list_versions": null,
    "created_at": "2015-03-03T14:06:58.394-03:00",
    "updated_at": "2015-03-03T14:06:58.394-03:00",
    "permissions": {
      "can_execute_step": [],
      "can_view_step": []
    },
    "version_id": null,
    "active": true,
    "id": 2,
    "title": "Etaoa 2",
    "conduction_mode_open": true,
    "step_type": "form",
    "child_flow": null,
    "my_child_flow": null,
    "fields": [],
    "my_fields": []
  },
  "message": "Etapa criada com sucesso"
}
```
___

### Editing a Step <a name="update"></a>

Endpoint: `/flows/:flow_id/steps/:id`

Method: put

#### Input Parameters

| Name                  | Type    | Required   | Description                                                              |
|-----------------------|---------|------------|--------------------------------------------------------------------------|
| title                 | String  | Yes        | Step title. (up to 100 characters)                                       |
| step_type             | String  | Yes        | Step type. ('flow' or 'form')                                            |
| conduction_modeo_open | Boolean | No         | Step conduction mode. (by default is Open/true)                          |
| child_flow_id         | Integer | No         | If step_type is flow it is necessary to inform the child Flow's id       |
| child_flow_version    | Integer | No         | If step_type is flow it is necessary to informe the child Flow's version |


#### HTTP status

| Code | Description               |
|------|---------------------------|
| 400  | Invalid parameters.       |
| 401  | Unauthorized access.      |
| 404  | Does not exist.           |
| 200  | If successfully updated.  |


#### Example

##### Request
```json
{
  "title": "Novo Título da Etapa"
}
```

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Etapa atualizada com sucesso"
}
```
___

### Deleting <a name="delete"></a>

Endpoint: `/flows/:flow_id/steps/:id`

Method: delete

If there's any Case created for the parent Flow of the Step (you can check it through the GET option of the Flow and the attribute "total_cases"), the Step won't be deleted and will be inactivated; if there is no Cases it will be physically deleted.

#### Input Parameters

No input parameters, just the **id** in the URL.

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
  "message": "Etapa apagada com sucesso"
}
```

___

### Permission <a name="permission"></a>

Change group permissions that can visualize or run the indicated step.

Endpoint: `/flows/:flow_id/steps/:id/permissions`

Method: PUT

#### Input Parameters

| Name            | Type    | Required  | Description                          |
|-----------------|---------|-----------|--------------------------------------|
| group_ids       | Array   | Yes       | Array of Group IDs to be updated.    |
| permission_type | String  | Yes       | Permission type to be added.         |

#### Permission types

| Permission                | Parameter     | Description                                         |
|---------------------------|---------------|-----------------------------------------------------|
| can_execute_step          | Step ID       | Can visualize and run/update a Step of the Case.    |
| can_view_step             | Step ID       | Can visualize a Step of the Case.                   |

#### HTTP status

| Code | Description                |
|------|----------------------------|
| 400  | Permission does not exist. |
| 401  | Unauthorized access.       |
| 404  | Does not exist.            |
| 200  | If successfully updated.   |


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