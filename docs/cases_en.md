# ZUP-API Documentation - Cases

## Protocol

The adopted protocol is REST, and a JSON is received as the input parameter. It is necessary to perform an authentication request and to use a TOKEN in the requests to this Endpoint. The creation of a complete Flow (with Steps and Fields) is also required for proper usage of this endpoint.

Endpoint Staging: `http://staging.zup.sapience.io/cases`

Example of how to carry out a request using cURL tool:

```bash
curl -X POST --data-binary @case-data.json -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/cases
```
Or
```bash
curl -X POST --data-binary '{"campo":"valor"}' -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/cases
```

## Services

### Content

* [Create](#create)
* [List](#list)
* [Display](#show)
* [Update / Advance Step](#update)
* [Finalize](#finish)
* [Transfer to another Flow](#transfer)
* [Inactivate](#inactive)
* [Restore](#restore)
* [Update Case Step](#update_case_step)
* [Permissions](#permissions)

___

### Creating <a name="create"></a>

Case creation occurs when the data of the first Step are sent.
If "fields" is not sent, the first Step is just initiated, and won't be executed. 

Endpoint: `/cases`

Method: post

#### Input Parameters

| Name                 | Type    | Required | Description                                                      |
|----------------------|---------|----------|------------------------------------------------------------------|
| initial_flow_id      | Integer | Yes      | Initial Flow ID using the current version (parent of all flows). |
| fields               | Array   | No       | Array of Hash with Field ID and Value with  the field's Value (the value will be converted into the correct field value in order to verify the field's validations). |
| responsible_user_id  | Integer | No       | User ID to be responsible for the Step of the Case.                         |
| responsible_group_id | Integer | No       | Group ID to be responsible for the Step of the Case.                        |

#### HTTP status

| Code | Description                        |
|------|------------------------------------|
| 400  | Invalid parameters                 |
| 400  | Step is disabled                   |
| 400  | Step does not belong to the Case   |
| 400  | Current Step was not filled in     |
| 401  | Unauthorized access                |
| 201  | If successfully created            |


#### Example

##### Request
```json
{
  "initial_flow_id": 2,
  "fields": [
    {"id": 1, "value": "10"}
  ]
}
```

##### Response

###### Failure
```
Status: 400
Content-Type: application/json
```

```json
{
  "error": {
    "case_steps.fields": [
      "new_age não pode ficar em branco",
      "new_age deve ser maior que 10"
    ]
  }
}
```

###### Success

An entry is created in CasesLogEntries with 'create_case' action.

When creating a Case the return has display_type = 'full'.

If a Trigger is executed at the end of the Case, **trigger_values** and **trigger_type** will be filled in the return.

**trigger_values** will have item ID

**trigger_type** will have one of the values: "enable_steps", "disable_steps", "finish_flow", "transfer_flow"

```
Status: 201
Content-Type: application/json
```

| Name     | Type    | Description                   |
|----------|---------|-------------------------------|
| case     | Object  | See CaseObject get /cases/1   |

```json
{
  "trigger_description": null,
  "trigger_values": null,
  "trigger_type": null,
  "case": {
    "steps": [
      {
        "steps": [],
        "flow": {
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
        "step": {
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
      },
      {
        "steps": [],
        "flow": null,
        "step": {
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
        }
      },
      {
        "steps": [],
        "flow": null,
        "step": {
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
      }
    ],
    "current_step": {
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
          "flow_can_execute_all_steps": [
            3
          ],
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
              "flow_can_execute_all_steps": [
                3
              ],
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
      "case_step_data_fields": [],
      "created_at": "2015-03-04T11:11:46.894-03:00",
      "updated_at": "2015-03-04T11:11:46.894-03:00",
      "id": 1,
      "step_id": 5,
      "step_version": 6,
      "my_step": {
        "list_versions": [
          {
            "created_at": "2015-03-04T00:30:06.214-03:00",
            "updated_at": "2015-03-04T00:51:47.232-03:00",
            "permissions": {
              "can_execute_step": [],
              "can_view_step": []
            },
            "version_id": 6,
            "active": true,
            "id": 5,
            "title": "Etapa 2",
            "conduction_mode_open": true,
            "step_type": "form",
            "child_flow": null,
            "my_child_flow": null,
            "fields": [
              {
                "draft": false,
                "step_id": 5,
                "active": true,
                "origin_field_id": null,
                "category_report_id": null,
                "category_inventory_id": null,
                "field_type": "text",
                "title": "Campo 1",
                "id": 3,
                "created_at": "2015-03-04T00:30:27.297-03:00",
                "updated_at": "2015-03-04T00:51:47.224-03:00",
                "multiple": false,
                "filter": null,
                "requirements": null,
                "values": null,
                "user_id": 1,
                "origin_field_version": null
              }
            ],
            "my_fields": [
              {
                "draft": false,
                "step_id": 5,
                "active": true,
                "origin_field_id": null,
                "category_report_id": null,
                "category_inventory_id": null,
                "field_type": "text",
                "title": "Campo 1",
                "id": 3,
                "created_at": "2015-03-04T00:30:27.297-03:00",
                "updated_at": "2015-03-04T00:51:47.224-03:00",
                "multiple": false,
                "filter": null,
                "requirements": null,
                "values": null,
                "user_id": 1,
                "origin_field_version": null
              }
            ]
          }
        ],
        "created_at": "2015-03-04T00:30:06.214-03:00",
        "updated_at": "2015-03-04T00:51:47.232-03:00",
        "permissions": {
          "can_execute_step": [],
          "can_view_step": []
        },
        "version_id": 6,
        "active": true,
        "id": 5,
        "title": "Etapa 2",
        "conduction_mode_open": true,
        "step_type": "form",
        "child_flow": null,
        "my_child_flow": null,
        "fields": [
          {
            "draft": false,
            "step_id": 5,
            "active": true,
            "origin_field_id": null,
            "category_report_id": null,
            "category_inventory_id": null,
            "field_type": "text",
            "title": "Campo 1",
            "id": 3,
            "created_at": "2015-03-04T00:30:27.297-03:00",
            "updated_at": "2015-03-04T00:51:47.224-03:00",
            "multiple": false,
            "filter": null,
            "requirements": null,
            "values": null,
            "user_id": 1,
            "origin_field_version": null
          }
        ],
        "my_fields": [
          {
            "draft": false,
            "step_id": 5,
            "active": true,
            "origin_field_id": null,
            "category_report_id": null,
            "category_inventory_id": null,
            "field_type": "text",
            "title": "Campo 1",
            "id": 3,
            "created_at": "2015-03-04T00:30:27.297-03:00",
            "updated_at": "2015-03-04T00:51:47.224-03:00",
            "multiple": false,
            "filter": null,
            "requirements": null,
            "values": null,
            "user_id": 1,
            "origin_field_version": null
          }
        ]
      },
      "trigger_ids": [],
      "responsible_user_id": 1,
      "responsible_group_id": null,
      "executed": true
    },
    "case_steps": [
      {
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
            "flow_can_execute_all_steps": [
              3
            ],
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
                "flow_can_execute_all_steps": [
                  3
                ],
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
        "case_step_data_fields": [],
        "created_at": "2015-03-04T11:11:46.894-03:00",
        "updated_at": "2015-03-04T11:11:46.894-03:00",
        "id": 1,
        "step_id": 5,
        "step_version": 6,
        "my_step": {
          "list_versions": [
            {
              "created_at": "2015-03-04T00:30:06.214-03:00",
              "updated_at": "2015-03-04T00:51:47.232-03:00",
              "permissions": {
                "can_execute_step": [],
                "can_view_step": []
              },
              "version_id": 6,
              "active": true,
              "id": 5,
              "title": "Etapa 2",
              "conduction_mode_open": true,
              "step_type": "form",
              "child_flow": null,
              "my_child_flow": null,
              "fields": [
                {
                  "draft": false,
                  "step_id": 5,
                  "active": true,
                  "origin_field_id": null,
                  "category_report_id": null,
                  "category_inventory_id": null,
                  "field_type": "text",
                  "title": "Campo 1",
                  "id": 3,
                  "created_at": "2015-03-04T00:30:27.297-03:00",
                  "updated_at": "2015-03-04T00:51:47.224-03:00",
                  "multiple": false,
                  "filter": null,
                  "requirements": null,
                  "values": null,
                  "user_id": 1,
                  "origin_field_version": null
                }
              ],
              "my_fields": [
                {
                  "draft": false,
                  "step_id": 5,
                  "active": true,
                  "origin_field_id": null,
                  "category_report_id": null,
                  "category_inventory_id": null,
                  "field_type": "text",
                  "title": "Campo 1",
                  "id": 3,
                  "created_at": "2015-03-04T00:30:27.297-03:00",
                  "updated_at": "2015-03-04T00:51:47.224-03:00",
                  "multiple": false,
                  "filter": null,
                  "requirements": null,
                  "values": null,
                  "user_id": 1,
                  "origin_field_version": null
                }
              ]
            }
          ],
          "created_at": "2015-03-04T00:30:06.214-03:00",
          "updated_at": "2015-03-04T00:51:47.232-03:00",
          "permissions": {
            "can_execute_step": [],
            "can_view_step": []
          },
          "version_id": 6,
          "active": true,
          "id": 5,
          "title": "Etapa 2",
          "conduction_mode_open": true,
          "step_type": "form",
          "child_flow": null,
          "my_child_flow": null,
          "fields": [
            {
              "draft": false,
              "step_id": 5,
              "active": true,
              "origin_field_id": null,
              "category_report_id": null,
              "category_inventory_id": null,
              "field_type": "text",
              "title": "Campo 1",
              "id": 3,
              "created_at": "2015-03-04T00:30:27.297-03:00",
              "updated_at": "2015-03-04T00:51:47.224-03:00",
              "multiple": false,
              "filter": null,
              "requirements": null,
              "values": null,
              "user_id": 1,
              "origin_field_version": null
            }
          ],
          "my_fields": [
            {
              "draft": false,
              "step_id": 5,
              "active": true,
              "origin_field_id": null,
              "category_report_id": null,
              "category_inventory_id": null,
              "field_type": "text",
              "title": "Campo 1",
              "id": 3,
              "created_at": "2015-03-04T00:30:27.297-03:00",
              "updated_at": "2015-03-04T00:51:47.224-03:00",
              "multiple": false,
              "filter": null,
              "requirements": null,
              "values": null,
              "user_id": 1,
              "origin_field_version": null
            }
          ]
        },
        "trigger_ids": [],
        "responsible_user_id": 1,
        "responsible_group_id": null,
        "executed": true
      }
    ],
    "original_case": null,
    "get_responsible_group": null,
    "get_responsible_user": {
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
        "flow_can_execute_all_steps": [
          3
        ],
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
            "flow_can_execute_all_steps": [
              3
            ],
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
        "flow_can_execute_all_steps": [
          3
        ],
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
            "flow_can_execute_all_steps": [
              3
            ],
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
    "completed": false,
    "steps_not_fulfilled": [
      4
    ],
    "total_steps": 2,
    "flow_version": 8,
    "initial_flow_id": 3,
    "updated_at": "2015-03-04T11:11:46.891-03:00",
    "created_at": "2015-03-04T11:11:46.891-03:00",
    "updated_by_id": null,
    "created_by_id": 1,
    "id": 1,
    "disabled_steps": [],
    "original_case_id": null,
    "children_case_ids": [],
    "case_step_ids": [
      1
    ],
    "next_step_id": 5,
    "responsible_user_id": 1,
    "responsible_group_id": null,
    "status": "active"
  },
  "message": "Caso criado com sucesso"
}
```
___

### List <a name="list"></a>

Endpoint: `/cases`

Method: get

#### Input Parameters

| Name                 | Type    | Required  | Description                                          |
|----------------------|---------|-----------|------------------------------------------------------|
| display_type         | String  | No        | To return all the data use the parameter as 'full'.  |
| initial_flow_id      | String  | No        | Initial Flow IDs (separated by comma).               |
| initial_flow_version | String  | No        | Initial Flow versions (separated by comma).          |
| responsible_user_id  | String  | No        | Users IDs (separated by comma).                      |
| responsible_group_id | String  | No        | Groups IDs (separated by comma).                     |
| created_by_id        | String  | No        | Users IDs (separated by comma).                      |
| updated_by_id        | String  | No        | Users IDs (separated by comma).                      |
| step_id              | String  | No        | Steps IDs (separated by comma).                      |
| per_page             | Integer | No        | Number of Cases per page.                            |
| page                 | Integer | No        | Number of pages.                                     |

#### HTTP status

| Code | Description                     |
|------|---------------------------------|
| 401  | Unauthorized access.            |
| 200  | If there are one or more items. |


#### Example

##### Request
```json
?display_type=full
```

##### Response
```
Status: 200
Content-Type: application/json
```

| Name     | Type    | Description                     |
|----------|---------|---------------------------------|
| case     | Object  | See CaseObject get /cases/1     |

**Without display_type**
```json
{
  "cases": [
    {
      "completed": false,
      "steps_not_fulfilled": [],
      "total_steps": 1,
      "flow_version": 12,
      "initial_flow_id": 6,
      "updated_at": "2015-03-04T12:11:21.810-03:00",
      "created_at": "2015-03-04T12:11:21.810-03:00",
      "updated_by_id": null,
      "created_by_id": 1,
      "id": 2,
      "disabled_steps": [],
      "original_case_id": 1,
      "children_case_ids": [],
      "case_step_ids": [],
      "next_step_id": 7,
      "responsible_user_id": null,
      "responsible_group_id": null,
      "status": "active"
    },
    {
      "completed": false,
      "steps_not_fulfilled": [
        4
      ],
      "total_steps": 2,
      "flow_version": 8,
      "initial_flow_id": 3,
      "updated_at": "2015-03-04T12:11:21.818-03:00",
      "created_at": "2015-03-04T11:11:46.891-03:00",
      "updated_by_id": 1,
      "created_by_id": 1,
      "id": 1,
      "disabled_steps": [],
      "original_case_id": null,
      "children_case_ids": [
        2
      ],
      "case_step_ids": [
        1
      ],
      "next_step_id": 4,
      "responsible_user_id": 1,
      "responsible_group_id": null,
      "status": "transfer"
    },
    {
      "completed": false,
      "steps_not_fulfilled": [
        4
      ],
      "total_steps": 2,
      "flow_version": 8,
      "initial_flow_id": 3,
      "updated_at": "2015-03-04T12:13:17.473-03:00",
      "created_at": "2015-03-04T12:12:41.309-03:00",
      "updated_by_id": 1,
      "created_by_id": 1,
      "id": 3,
      "disabled_steps": [],
      "original_case_id": null,
      "children_case_ids": [],
      "case_step_ids": [
        2
      ],
      "next_step_id": 4,
      "responsible_user_id": 1,
      "responsible_group_id": null,
      "status": "active"
    }
  ]
}
```

**With display_type=full**
The return is an extensive Array of CaseObject (see get /cases/1) with display_type=full
```json
{
  "cases": [CaseObject, CaseObject]
}
```
___

### Display <a name="show"></a>

Endpoint: `/cases/:id`

Method: get

#### Input Parameters

| Name            | Type    | Required  | Description                                            |
|-----------------|---------|-----------|--------------------------------------------------------|
| display_type    | String  | No        | To return all the data use the parameter as 'full'.    |

#### HTTP status

| Code | Description      |
|------|------------------|
| 404  | Not found.       |
| 200  | Return Case.     |


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

###### CaseObject
| Name                       | Type       | Description                                                                       |
|----------------------------|------------|-----------------------------------------------------------------------------------|
| id                         | Integer    | Object ID                                                                         |
| updated_at                 | DateTime   | Date and time of the last update of the object                                    |
| updated_by                 | Object     | Object of the user who updated the object                                         |
| updated_by_id              | Integer    | ID of the user who updated the object                                             |
| created_at                 | DateTime   | Date and time of creation of the object                                           |
| created_by                 | Object     | Object of the user who created the Case                                           |
| created_by_id              | Integer    | ID of the user who created the Case                                               |
| total_steps                | Integer    | Total number of Steps of the Case                                                 |
| get_responsible_group      | Object     | Group responsible for the current Step                                            |
| get_responsible_group      | Object     | Group responsible for the current Step                                            |
| responsible_user_id        | Integer    | ID of the User responsible for the current Step                                   |
| responsible_group_id       | Integer    | ID of the Group responsible for the current Step                                  |
| get_responsible_user       | Object     | User responsible for the current Step                                             |
| status                     | String     | Case status (active, pending, finished, inactive, transfer or not_satisfied)      |
| completed                  | Boolean    | Whether the Case is complete                                                      |
| case_steps                 | Array      | Array of Steps filled in the Case (see CaseStepObject)                            |
| original_case              | Object     | Original Case object, when a Case has been transferred to another Flow            |
| original_case_id           | Integer    | Original Case object ID, when a Case has been transferred to another Flow         |
| children_case_id           | Integer    | Object ID of the child Case, when a Case has been transferred to another Flow     |
| case_step_ids              | Array      | Array of filled Steps IDs (it is not the ID of the Step of the Flow)              |
| initial_flow_id            | Integer    | ID of the Initial Flow used                                                       |
| flow_version               | Integer    | ID of the Initial Flow version                                                    |
| current_step               | Object     | Current Step object (see CaseStepObject), last Step filled in                     |
| steps                      | Array      | Tree of Array of all Steps of the Case (based on the Initial Flow)                |
| disabled_steps             | Array      | Steps IDs disabled by Triggers                                                    |
| steps_not_fulfilled        | Array      | Steps IDs not filled in when Case status is 'not satisfied'                       |
| next_step_id               | Integer    | Next Step's ID to be filled in                                                    |

**Without display_type**
```json
{
  "case": {
    "completed": false,
    "steps_not_fulfilled": [
      4
    ],
    "total_steps": 2,
    "flow_version": 8,
    "initial_flow_id": 3,
    "updated_at": "2015-03-04T11:21:27.385-03:00",
    "created_at": "2015-03-04T11:11:46.891-03:00",
    "updated_by_id": 1,
    "created_by_id": 1,
    "id": 1,
    "disabled_steps": [],
    "original_case_id": null,
    "children_case_ids": [],
    "case_step_ids": [
      1
    ],
    "next_step_id": 4,
    "responsible_user_id": 1,
    "responsible_group_id": null,
    "status": "active"
  }
}
```

**With display_type=full**
```json
{
  "case": {
    "steps": [
      {
        "steps": [],
        "flow": {
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
        "step": {
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
      },
      {
        "steps": [],
        "flow": null,
        "step": {
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
        }
      },
      {
        "steps": [],
        "flow": null,
        "step": {
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
      }
    ],
    "current_step": {
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
          "flow_can_execute_all_steps": [
            3
          ],
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
              "flow_can_execute_all_steps": [
                3
              ],
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
          "flow_can_execute_all_steps": [
            3
          ],
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
              "flow_can_execute_all_steps": [
                3
              ],
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
      "case_step_data_fields": [
        {
          "case_step_data_attachments": [],
          "case_step_data_images": [],
          "value": "teste",
          "field": {
            "list_versions": [
              {
                "previous_field": null,
                "created_at": "2015-03-04T00:29:36.020-03:00",
                "updated_at": "2015-03-04T00:51:47.192-03:00",
                "version_id": 3,
                "active": true,
                "values": null,
                "id": 2,
                "title": "Campo 1",
                "field_type": "text",
                "filter": null,
                "origin_field_id": null,
                "category_inventory": null,
                "category_report": null,
                "requirements": {
                  "presence": "true"
                }
              }
            ],
            "previous_field": null,
            "created_at": "2015-03-04T00:29:36.020-03:00",
            "updated_at": "2015-03-04T00:51:47.192-03:00",
            "version_id": null,
            "active": true,
            "values": null,
            "id": 2,
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
          "id": 1
        }
      ],
      "created_at": "2015-03-04T11:11:46.894-03:00",
      "updated_at": "2015-03-04T11:21:27.267-03:00",
      "id": 1,
      "step_id": 5,
      "step_version": 6,
      "my_step": {
        "list_versions": [
          {
            "created_at": "2015-03-04T00:30:06.214-03:00",
            "updated_at": "2015-03-04T00:51:47.232-03:00",
            "permissions": {
              "can_execute_step": [],
              "can_view_step": []
            },
            "version_id": 6,
            "active": true,
            "id": 5,
            "title": "Etapa 2",
            "conduction_mode_open": true,
            "step_type": "form",
            "child_flow": null,
            "my_child_flow": null,
            "fields": [
              {
                "draft": false,
                "step_id": 5,
                "active": true,
                "origin_field_id": null,
                "category_report_id": null,
                "category_inventory_id": null,
                "field_type": "text",
                "title": "Campo 1",
                "id": 3,
                "created_at": "2015-03-04T00:30:27.297-03:00",
                "updated_at": "2015-03-04T00:51:47.224-03:00",
                "multiple": false,
                "filter": null,
                "requirements": null,
                "values": null,
                "user_id": 1,
                "origin_field_version": null
              }
            ],
            "my_fields": [
              {
                "draft": false,
                "step_id": 5,
                "active": true,
                "origin_field_id": null,
                "category_report_id": null,
                "category_inventory_id": null,
                "field_type": "text",
                "title": "Campo 1",
                "id": 3,
                "created_at": "2015-03-04T00:30:27.297-03:00",
                "updated_at": "2015-03-04T00:51:47.224-03:00",
                "multiple": false,
                "filter": null,
                "requirements": null,
                "values": null,
                "user_id": 1,
                "origin_field_version": null
              }
            ]
          }
        ],
        "created_at": "2015-03-04T00:30:06.214-03:00",
        "updated_at": "2015-03-04T00:51:47.232-03:00",
        "permissions": {
          "can_execute_step": [],
          "can_view_step": []
        },
        "version_id": 6,
        "active": true,
        "id": 5,
        "title": "Etapa 2",
        "conduction_mode_open": true,
        "step_type": "form",
        "child_flow": null,
        "my_child_flow": null,
        "fields": [
          {
            "draft": false,
            "step_id": 5,
            "active": true,
            "origin_field_id": null,
            "category_report_id": null,
            "category_inventory_id": null,
            "field_type": "text",
            "title": "Campo 1",
            "id": 3,
            "created_at": "2015-03-04T00:30:27.297-03:00",
            "updated_at": "2015-03-04T00:51:47.224-03:00",
            "multiple": false,
            "filter": null,
            "requirements": null,
            "values": null,
            "user_id": 1,
            "origin_field_version": null
          }
        ],
        "my_fields": [
          {
            "draft": false,
            "step_id": 5,
            "active": true,
            "origin_field_id": null,
            "category_report_id": null,
            "category_inventory_id": null,
            "field_type": "text",
            "title": "Campo 1",
            "id": 3,
            "created_at": "2015-03-04T00:30:27.297-03:00",
            "updated_at": "2015-03-04T00:51:47.224-03:00",
            "multiple": false,
            "filter": null,
            "requirements": null,
            "values": null,
            "user_id": 1,
            "origin_field_version": null
          }
        ]
      },
      "trigger_ids": [],
      "responsible_user_id": 1,
      "responsible_group_id": null,
      "executed": true
    },
    "case_steps": [
      {
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
            "flow_can_execute_all_steps": [
              3
            ],
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
                "flow_can_execute_all_steps": [
                  3
                ],
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
            "flow_can_execute_all_steps": [
              3
            ],
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
                "flow_can_execute_all_steps": [
                  3
                ],
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
        "case_step_data_fields": [
          {
            "case_step_data_attachments": [],
            "case_step_data_images": [],
            "value": "teste",
            "field": {
              "list_versions": [
                {
                  "previous_field": null,
                  "created_at": "2015-03-04T00:29:36.020-03:00",
                  "updated_at": "2015-03-04T00:51:47.192-03:00",
                  "version_id": 3,
                  "active": true,
                  "values": null,
                  "id": 2,
                  "title": "Campo 1",
                  "field_type": "text",
                  "filter": null,
                  "origin_field_id": null,
                  "category_inventory": null,
                  "category_report": null,
                  "requirements": {
                    "presence": "true"
                  }
                }
              ],
              "previous_field": null,
              "created_at": "2015-03-04T00:29:36.020-03:00",
              "updated_at": "2015-03-04T00:51:47.192-03:00",
              "version_id": null,
              "active": true,
              "values": null,
              "id": 2,
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
            "id": 1
          }
        ],
        "created_at": "2015-03-04T11:11:46.894-03:00",
        "updated_at": "2015-03-04T11:21:27.267-03:00",
        "id": 1,
        "step_id": 5,
        "step_version": 6,
        "my_step": {
          "list_versions": [
            {
              "created_at": "2015-03-04T00:30:06.214-03:00",
              "updated_at": "2015-03-04T00:51:47.232-03:00",
              "permissions": {
                "can_execute_step": [],
                "can_view_step": []
              },
              "version_id": 6,
              "active": true,
              "id": 5,
              "title": "Etapa 2",
              "conduction_mode_open": true,
              "step_type": "form",
              "child_flow": null,
              "my_child_flow": null,
              "fields": [
                {
                  "draft": false,
                  "step_id": 5,
                  "active": true,
                  "origin_field_id": null,
                  "category_report_id": null,
                  "category_inventory_id": null,
                  "field_type": "text",
                  "title": "Campo 1",
                  "id": 3,
                  "created_at": "2015-03-04T00:30:27.297-03:00",
                  "updated_at": "2015-03-04T00:51:47.224-03:00",
                  "multiple": false,
                  "filter": null,
                  "requirements": null,
                  "values": null,
                  "user_id": 1,
                  "origin_field_version": null
                }
              ],
              "my_fields": [
                {
                  "draft": false,
                  "step_id": 5,
                  "active": true,
                  "origin_field_id": null,
                  "category_report_id": null,
                  "category_inventory_id": null,
                  "field_type": "text",
                  "title": "Campo 1",
                  "id": 3,
                  "created_at": "2015-03-04T00:30:27.297-03:00",
                  "updated_at": "2015-03-04T00:51:47.224-03:00",
                  "multiple": false,
                  "filter": null,
                  "requirements": null,
                  "values": null,
                  "user_id": 1,
                  "origin_field_version": null
                }
              ]
            }
          ],
          "created_at": "2015-03-04T00:30:06.214-03:00",
          "updated_at": "2015-03-04T00:51:47.232-03:00",
          "permissions": {
            "can_execute_step": [],
            "can_view_step": []
          },
          "version_id": 6,
          "active": true,
          "id": 5,
          "title": "Etapa 2",
          "conduction_mode_open": true,
          "step_type": "form",
          "child_flow": null,
          "my_child_flow": null,
          "fields": [
            {
              "draft": false,
              "step_id": 5,
              "active": true,
              "origin_field_id": null,
              "category_report_id": null,
              "category_inventory_id": null,
              "field_type": "text",
              "title": "Campo 1",
              "id": 3,
              "created_at": "2015-03-04T00:30:27.297-03:00",
              "updated_at": "2015-03-04T00:51:47.224-03:00",
              "multiple": false,
              "filter": null,
              "requirements": null,
              "values": null,
              "user_id": 1,
              "origin_field_version": null
            }
          ],
          "my_fields": [
            {
              "draft": false,
              "step_id": 5,
              "active": true,
              "origin_field_id": null,
              "category_report_id": null,
              "category_inventory_id": null,
              "field_type": "text",
              "title": "Campo 1",
              "id": 3,
              "created_at": "2015-03-04T00:30:27.297-03:00",
              "updated_at": "2015-03-04T00:51:47.224-03:00",
              "multiple": false,
              "filter": null,
              "requirements": null,
              "values": null,
              "user_id": 1,
              "origin_field_version": null
            }
          ]
        },
        "trigger_ids": [],
        "responsible_user_id": 1,
        "responsible_group_id": null,
        "executed": true
      }
    ],
    "original_case": null,
    "get_responsible_group": null,
    "get_responsible_user": {
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
        "flow_can_execute_all_steps": [
          3
        ],
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
            "flow_can_execute_all_steps": [
              3
            ],
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
        "flow_can_execute_all_steps": [
          3
        ],
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
            "flow_can_execute_all_steps": [
              3
            ],
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
        "flow_can_execute_all_steps": [
          3
        ],
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
            "flow_can_execute_all_steps": [
              3
            ],
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
    "completed": false,
    "steps_not_fulfilled": [
      4
    ],
    "total_steps": 2,
    "flow_version": 8,
    "initial_flow_id": 3,
    "updated_at": "2015-03-04T11:21:27.385-03:00",
    "created_at": "2015-03-04T11:11:46.891-03:00",
    "updated_by_id": 1,
    "created_by_id": 1,
    "id": 1,
    "disabled_steps": [],
    "original_case_id": null,
    "children_case_ids": [],
    "case_step_ids": [
      1
    ],
    "next_step_id": 4,
    "responsible_user_id": 1,
    "responsible_group_id": null,
    "status": "active"
  }
}
``
___

### Update / Forward Step <a name="update"></a>

Endpoint: `/cases/:id`

Method: put

#### Input Parameters 

| Name                 | Type    | Required  | Description                               |
|----------------------|---------|-----------|-------------------------------------------|
| step_id              | Integer | Yes       | ID of the first Step of the Flow.         |
| fields               | Array   | Yes       | Array of Hash with Field ID and Value with the field's Value (the value will be converted into the correct field value in order to verify the field's validations). |
| responsible_user_id  | Integer | No        | User ID to be responsible for the Step of the Case.  |
| responsible_group_id | Integer | No        | Group ID to be responsible for the Step of the Case. |

#### HTTP status

| Code | Description                        |
|------|------------------------------------|
| 400  | Invalid parameters                 |
| 400  | Step is disabled                   |
| 400  | Step does not belong to the Case   |
| 400  | Current Step was not filled in     |
| 401  | Unauthorized access                |
| 405  | Case is finalized                  |
| 200  | Step successfully updated          |

#### Example

##### Request
```json
{
  "step_id": 1,
  "fields": [
    {"id": 1, "value": "1"}
  ]
}
```

##### Response

###### Failure
```
Status: 400
Content-Type: application/json
```

```json
{
  "error": {
    "case_steps.fields": [
      "new_age deve ser maior que 10"
    ]
  }
}
```

###### Success

An entry is created in CasesLogEntries with the 'next_step' action (if it is a new Step) or 'update_step' (if it is an update of an existing Step in the Case).

When creating a Case the return has display_type = 'full'.

If it is the last Case Step, the Case will be finalized and an entry will be created in CasesLogEntries with 'finished' action.

If any Step is disabled by a Trigger and after that any other Step disabled it, when you try to finalize the Case it will be 'not satisfied' and will return those Steps IDs in 'steps_not_fulfilled'. The Case will automatically be finalized as soon as no more Steps are found in 'steps_not_fulfilled'.

If a Trigger is executed at the end of the Case, **trigger_values** and **trigger_type** will be filled in the return.

**trigger_values** will have the item's ID

**trigger_type** will have one of the values: "enable_steps", "disable_steps", "finish_flow", "transfer_flow"
 
```
Status: 200
Content-Type: application/json
```

```json
{
  "trigger_description": null,
  "trigger_values": null,
  "trigger_type": null,
  "case": {
    "steps": [
      {
        "steps": [],
        "flow": {
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
        "step": {
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
      },
      {
        "steps": [],
        "flow": null,
        "step": {
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
        }
      },
      {
        "steps": [],
        "flow": null,
        "step": {
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
      }
    ],
    "current_step": {
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
          "flow_can_execute_all_steps": [
            3
          ],
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
              "flow_can_execute_all_steps": [
                3
              ],
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
          "flow_can_execute_all_steps": [
            3
          ],
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
              "flow_can_execute_all_steps": [
                3
              ],
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
      "case_step_data_fields": [
        {
          "case_step_data_attachments": [],
          "case_step_data_images": [],
          "value": "teste",
          "field": {
            "list_versions": [
              {
                "previous_field": null,
                "created_at": "2015-03-04T00:29:36.020-03:00",
                "updated_at": "2015-03-04T00:51:47.192-03:00",
                "version_id": 3,
                "active": true,
                "values": null,
                "id": 2,
                "title": "Campo 1",
                "field_type": "text",
                "filter": null,
                "origin_field_id": null,
                "category_inventory": null,
                "category_report": null,
                "requirements": {
                  "presence": "true"
                }
              }
            ],
            "previous_field": null,
            "created_at": "2015-03-04T00:29:36.020-03:00",
            "updated_at": "2015-03-04T00:51:47.192-03:00",
            "version_id": null,
            "active": true,
            "values": null,
            "id": 2,
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
          "id": 1
        }
      ],
      "created_at": "2015-03-04T11:11:46.894-03:00",
      "updated_at": "2015-03-04T11:21:27.267-03:00",
      "id": 1,
      "step_id": 5,
      "step_version": 6,
      "my_step": {
        "list_versions": [
          {
            "created_at": "2015-03-04T00:30:06.214-03:00",
            "updated_at": "2015-03-04T00:51:47.232-03:00",
            "permissions": {
              "can_execute_step": [],
              "can_view_step": []
            },
            "version_id": 6,
            "active": true,
            "id": 5,
            "title": "Etapa 2",
            "conduction_mode_open": true,
            "step_type": "form",
            "child_flow": null,
            "my_child_flow": null,
            "fields": [
              {
                "draft": false,
                "step_id": 5,
                "active": true,
                "origin_field_id": null,
                "category_report_id": null,
                "category_inventory_id": null,
                "field_type": "text",
                "title": "Campo 1",
                "id": 3,
                "created_at": "2015-03-04T00:30:27.297-03:00",
                "updated_at": "2015-03-04T00:51:47.224-03:00",
                "multiple": false,
                "filter": null,
                "requirements": null,
                "values": null,
                "user_id": 1,
                "origin_field_version": null
              }
            ],
            "my_fields": [
              {
                "draft": false,
                "step_id": 5,
                "active": true,
                "origin_field_id": null,
                "category_report_id": null,
                "category_inventory_id": null,
                "field_type": "text",
                "title": "Campo 1",
                "id": 3,
                "created_at": "2015-03-04T00:30:27.297-03:00",
                "updated_at": "2015-03-04T00:51:47.224-03:00",
                "multiple": false,
                "filter": null,
                "requirements": null,
                "values": null,
                "user_id": 1,
                "origin_field_version": null
              }
            ]
          }
        ],
        "created_at": "2015-03-04T00:30:06.214-03:00",
        "updated_at": "2015-03-04T00:51:47.232-03:00",
        "permissions": {
          "can_execute_step": [],
          "can_view_step": []
        },
        "version_id": 6,
        "active": true,
        "id": 5,
        "title": "Etapa 2",
        "conduction_mode_open": true,
        "step_type": "form",
        "child_flow": null,
        "my_child_flow": null,
        "fields": [
          {
            "draft": false,
            "step_id": 5,
            "active": true,
            "origin_field_id": null,
            "category_report_id": null,
            "category_inventory_id": null,
            "field_type": "text",
            "title": "Campo 1",
            "id": 3,
            "created_at": "2015-03-04T00:30:27.297-03:00",
            "updated_at": "2015-03-04T00:51:47.224-03:00",
            "multiple": false,
            "filter": null,
            "requirements": null,
            "values": null,
            "user_id": 1,
            "origin_field_version": null
          }
        ],
        "my_fields": [
          {
            "draft": false,
            "step_id": 5,
            "active": true,
            "origin_field_id": null,
            "category_report_id": null,
            "category_inventory_id": null,
            "field_type": "text",
            "title": "Campo 1",
            "id": 3,
            "created_at": "2015-03-04T00:30:27.297-03:00",
            "updated_at": "2015-03-04T00:51:47.224-03:00",
            "multiple": false,
            "filter": null,
            "requirements": null,
            "values": null,
            "user_id": 1,
            "origin_field_version": null
          }
        ]
      },
      "trigger_ids": [],
      "responsible_user_id": 1,
      "responsible_group_id": null,
      "executed": true
    },
    "case_steps": [
      {
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
            "flow_can_execute_all_steps": [
              3
            ],
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
                "flow_can_execute_all_steps": [
                  3
                ],
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
            "flow_can_execute_all_steps": [
              3
            ],
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
                "flow_can_execute_all_steps": [
                  3
                ],
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
        "case_step_data_fields": [
          {
            "case_step_data_attachments": [],
            "case_step_data_images": [],
            "value": "teste",
            "field": {
              "list_versions": [
                {
                  "previous_field": null,
                  "created_at": "2015-03-04T00:29:36.020-03:00",
                  "updated_at": "2015-03-04T00:51:47.192-03:00",
                  "version_id": 3,
                  "active": true,
                  "values": null,
                  "id": 2,
                  "title": "Campo 1",
                  "field_type": "text",
                  "filter": null,
                  "origin_field_id": null,
                  "category_inventory": null,
                  "category_report": null,
                  "requirements": {
                    "presence": "true"
                  }
                }
              ],
              "previous_field": null,
              "created_at": "2015-03-04T00:29:36.020-03:00",
              "updated_at": "2015-03-04T00:51:47.192-03:00",
              "version_id": null,
              "active": true,
              "values": null,
              "id": 2,
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
            "id": 1
          }
        ],
        "created_at": "2015-03-04T11:11:46.894-03:00",
        "updated_at": "2015-03-04T11:21:27.267-03:00",
        "id": 1,
        "step_id": 5,
        "step_version": 6,
        "my_step": {
          "list_versions": [
            {
              "created_at": "2015-03-04T00:30:06.214-03:00",
              "updated_at": "2015-03-04T00:51:47.232-03:00",
              "permissions": {
                "can_execute_step": [],
                "can_view_step": []
              },
              "version_id": 6,
              "active": true,
              "id": 5,
              "title": "Etapa 2",
              "conduction_mode_open": true,
              "step_type": "form",
              "child_flow": null,
              "my_child_flow": null,
              "fields": [
                {
                  "draft": false,
                  "step_id": 5,
                  "active": true,
                  "origin_field_id": null,
                  "category_report_id": null,
                  "category_inventory_id": null,
                  "field_type": "text",
                  "title": "Campo 1",
                  "id": 3,
                  "created_at": "2015-03-04T00:30:27.297-03:00",
                  "updated_at": "2015-03-04T00:51:47.224-03:00",
                  "multiple": false,
                  "filter": null,
                  "requirements": null,
                  "values": null,
                  "user_id": 1,
                  "origin_field_version": null
                }
              ],
              "my_fields": [
                {
                  "draft": false,
                  "step_id": 5,
                  "active": true,
                  "origin_field_id": null,
                  "category_report_id": null,
                  "category_inventory_id": null,
                  "field_type": "text",
                  "title": "Campo 1",
                  "id": 3,
                  "created_at": "2015-03-04T00:30:27.297-03:00",
                  "updated_at": "2015-03-04T00:51:47.224-03:00",
                  "multiple": false,
                  "filter": null,
                  "requirements": null,
                  "values": null,
                  "user_id": 1,
                  "origin_field_version": null
                }
              ]
            }
          ],
          "created_at": "2015-03-04T00:30:06.214-03:00",
          "updated_at": "2015-03-04T00:51:47.232-03:00",
          "permissions": {
            "can_execute_step": [],
            "can_view_step": []
          },
          "version_id": 6,
          "active": true,
          "id": 5,
          "title": "Etapa 2",
          "conduction_mode_open": true,
          "step_type": "form",
          "child_flow": null,
          "my_child_flow": null,
          "fields": [
            {
              "draft": false,
              "step_id": 5,
              "active": true,
              "origin_field_id": null,
              "category_report_id": null,
              "category_inventory_id": null,
              "field_type": "text",
              "title": "Campo 1",
              "id": 3,
              "created_at": "2015-03-04T00:30:27.297-03:00",
              "updated_at": "2015-03-04T00:51:47.224-03:00",
              "multiple": false,
              "filter": null,
              "requirements": null,
              "values": null,
              "user_id": 1,
              "origin_field_version": null
            }
          ],
          "my_fields": [
            {
              "draft": false,
              "step_id": 5,
              "active": true,
              "origin_field_id": null,
              "category_report_id": null,
              "category_inventory_id": null,
              "field_type": "text",
              "title": "Campo 1",
              "id": 3,
              "created_at": "2015-03-04T00:30:27.297-03:00",
              "updated_at": "2015-03-04T00:51:47.224-03:00",
              "multiple": false,
              "filter": null,
              "requirements": null,
              "values": null,
              "user_id": 1,
              "origin_field_version": null
            }
          ]
        },
        "trigger_ids": [],
        "responsible_user_id": 1,
        "responsible_group_id": null,
        "executed": true
      }
    ],
    "original_case": null,
    "get_responsible_group": null,
    "get_responsible_user": {
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
        "flow_can_execute_all_steps": [
          3
        ],
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
            "flow_can_execute_all_steps": [
              3
            ],
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
        "flow_can_execute_all_steps": [
          3
        ],
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
            "flow_can_execute_all_steps": [
              3
            ],
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
        "flow_can_execute_all_steps": [
          3
        ],
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
            "flow_can_execute_all_steps": [
              3
            ],
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
    "completed": false,
    "steps_not_fulfilled": [
      4
    ],
    "total_steps": 2,
    "flow_version": 8,
    "initial_flow_id": 3,
    "updated_at": "2015-03-04T11:21:27.385-03:00",
    "created_at": "2015-03-04T11:11:46.891-03:00",
    "updated_by_id": 1,
    "created_by_id": 1,
    "id": 1,
    "disabled_steps": [],
    "original_case_id": null,
    "children_case_ids": [],
    "case_step_ids": [
      1
    ],
    "next_step_id": 4,
    "responsible_user_id": 1,
    "responsible_group_id": null,
    "status": "active"
  },
  "message": "Etapa atualizada com sucesso"
}
```
___

### Finalize <a name="finish"></a>

To finalize a Case in advance.

Endpoint: `/cases/:id/finish`

Method: put

#### Input Parameters

| Name                | Type    | Required  | Description                       |
|---------------------|---------|-----------|-----------------------------------|
| resolution_state_id | Integer | Yes       | Resolution State ID for the Case. |

#### HTTP status

| Code | Description              |
|------|--------------------------|
| 400  | Invalid parameters.      |
| 401  | Unauthorized access.     |
| 200  | If successfully created. |


#### Example
##### Response

An entry in CasesLogEntries is created with 'finished' action.

```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Caso finalizado com sucesso"
}
```
___

### Transfer to another Flow <a name="transfer"></a>

Endpoint: `/cases/:id/transfer`

Method: put

#### Input Parameters

| Name         | Type    | Required  | Description                                           |
|--------------|---------|-----------|-------------------------------------------------------|
| flow_id      | Integer | Yes       | The new flow ID.                                      |
| display_type | String  | No        | To return all the data use the parameter as 'full'.  |

#### HTTP status

| Code | Description              |
|------|--------------------------|
| 400  | Invalid parameters.      |
| 401  | Unauthorized access.     |
| 200  | If successfully created. |


#### Example
##### Response

An entry is created in CasesLogEntries through the action 'transfer_flow' for the current Case and through the action 'create_case' for the new Case.

```
Status: 200
Content-Type: application/json
```

| Name  | Type    | Description                  |
|-------|---------|------------------------------|
| case  | Object  | See CaseObject get /cases/1  |


```json
{
  "case": {
    "completed": false,
    "steps_not_fulfilled": [],
    "total_steps": 1,
    "flow_version": 12,
    "initial_flow_id": 6,
    "updated_at": "2015-03-04T12:11:21.810-03:00",
    "created_at": "2015-03-04T12:11:21.810-03:00",
    "updated_by_id": null,
    "created_by_id": 1,
    "id": 2,
    "disabled_steps": [],
    "original_case_id": 1,
    "children_case_ids": [],
    "case_step_ids": [],
    "next_step_id": 7,
    "responsible_user_id": null,
    "responsible_group_id": null,
    "status": "active"
  },
  "message": "Caso atualizado com sucesso"
}
```
___

### Inactivate <a name="inactive"></a>

Endpoint: `/cases/:id`

Method: delete

#### Input Parameters

#### HTTP status

| Code | Description                  |
|------|------------------------------|
| 404  | Not found.                   |
| 200  | If successfully inactivated. |


#### Example
##### Response

An entry is created in CasesLogEntries with the action'delete_case'.

```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Caso removido com sucesso"
}
```
___

### Restore <a name="restore"></a>

Endpoint: `/cases/:id/restore`

Method: put

#### Input Parameters

#### HTTP status

| Code | Description               |
|------|---------------------------|
| 404  | Not found.                |
| 200  | If successfully restored. |


#### Example
##### Response

An entry is created in CasesLogEntries with the action 'restored_case'.

```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Caso recuperado com sucesso"
}
```
___

### Update Case Step <a name="update_case_step"></a>

At the moment 'responsible_user_id' and 'responsible_group_id' are the only values that can be updated.

Endpoint: `/cases/:id/case_steps/:case_step_id`

Method: put

#### Input Parameters 

| Name                 | Type    | Required  | Description                               |
|----------------------|---------|-----------|-------------------------------------------|
| responsible_user_id  | Integer | No        | User ID to be responsible for Case Step.  |
| responsible_group_id | Integer | No        | Group ID to be responsible for Case Step. |

#### HTTP status

| Code | Description              |
|------|--------------------------|
| 400  | Invalid parameters.      |
| 401  | Unauthorized access.     |
| 200  | If successfully updated. |


#### Example

##### Request
```json
{
  "responsible_user_id": 1
}
```

If any of the responsible parameters were sent, a new entry will be created in CasesLogEntries through the action 'transfer_case'.

```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Estado do Caso atualizado com sucesso"
}
```
___

### Permissions <a name="permissions"></a>

The permissions are stored in the user's Group inside the attribute permissions.

#### Permissions Types

| Permission                | Parameter | Description                                                                    |
|---------------------------|-----------|--------------------------------------------------------------------------------|
| can_execute_step          | Step ID   | Can visualize and run/update a Step of the Case.                               |
| can_view_step             | Step ID   | Can visualize a Step of the Case.                                              |
| can_execute_all_steps     | Step ID   | Can visualize and run all children Steps of the Flow (direct children).        |
| can_view_all_steps        | Step ID   | Can visualize all children Steps of the Flow (direct children).                |
| flow_can_delete_own_cases | Step ID   | Can delete/restore your own Cases (visualization permission is also required). |
| flow_can_delete_all_cases | Step ID   | Can delete/restore any Case (visualization permission is also required ).      |
