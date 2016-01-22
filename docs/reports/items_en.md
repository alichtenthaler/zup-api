# Reports

## Creating a report item

__URI__ `POST /reports/:category_id/items`

### Input parameters

| Name              | Type    | Required   | Description                                                                   |
|-------------------|---------|------------|-------------------------------------------------------------------------------|
| category_id       | Integer | Yes        | Report category id                                                            |
| inventory_item_id | Integer | No         | Inventory item id                                                             |
| latitude          | String  | No         | Report latitude. Will use inventory's if it is not filled.                    |
| longitude         | String  | No         | Report longitude. Will use inventory's if it is not filled.                   |
| description       | String  | No         | Report description                                                            |
| address           | String  | No         | Report full address                                                           |
| reference         | String  | No         | Address reference                                                             |
| number            | String  | No         | Address number                                                                |
| district          | String  | No         | Report district                                                               |
| city              | String  | No         | Report city                                                                   |
| state             | String  | No         | Report state                                                                  |
| country           | String  | No         | Report country                                                                |
| images            | Array   | No         | An array of images, encoded in base64 for this report                         |
| status_id         | Integer | No         | The report status, will use the default initial status of the report category |
| user_id           | Integer | No         | To associate an user with the report                                          |
| confidential      | Boolean | No         | Whether the report is confidential (it is not visible to the citizens)             |
| from_panel        | Boolean | No         |                                                                               |

Example of request:

`POST /reports/1/items`

    {
      "latitude": "-23.5734740",
      "longitude": "-46.6431520",
      "address": "Rua Abilio Soares, 140",
      "description": "Situação ruim",
      "reference": "Próximo ao Posto de Saúde"
    }

Example of response:

    {
        "report": {
            "id": 1824,
            "protocol": 1824000014649690,
            "address": "Rua Abilio Soares, 140",
            "position": {
                "latitude": -23.573474,
                "longitude": -46.643152
            },
            "description": null,
            "category_icon": {
                "url": "/uploads/reports/category/1/icons/valid_report_category_icon.png",
                "retina": {
                    "url": "/uploads/reports/category/1/icons/retina_valid_report_category_icon.png"
                },
                "default": {
                    "url": "/uploads/reports/category/1/icons/default_valid_report_category_icon.png"
                }
            },
            "inventory_categories": [],
            "images": [],
            "status": {
                "id": 2,
                "title": "Initial status",
                "color": "#ff0000",
                "initial": true,
                "final": false
            },
            "category": {
                "id": 1,
                "title": "Limpeza de Boca",
                "icon": {
                    "retina": {
                        "web": {
                            "active": "/uploads/reports/category/1/icons/retina_web_active_valid_report_category_icon.png",
                            "disabled": "/uploads/reports/category/1/icons/retina_web_disabled_valid_report_category_icon.png"
                        },
                        "mobile": {
                            "active": "/uploads/reports/category/1/icons/retina_mobile_active_valid_report_category_icon.png",
                            "disabled": "/uploads/reports/category/1/icons/retina_mobile_disabled_valid_report_category_icon.png"
                        }
                    },
                    "default": {
                        "web": {
                            "active": "/uploads/reports/category/1/icons/default_web_active_valid_report_category_icon.png",
                            "disabled": "/uploads/reports/category/1/icons/default_web_disabled_valid_report_category_icon.png"
                        },
                        "mobile": {
                            "active": "/uploads/reports/category/1/icons/default_mobile_active_valid_report_category_icon.png",
                            "disabled": "/uploads/reports/category/1/icons/default_mobile_disabled_valid_report_category_icon.png"
                        }
                    }
                },
                "marker": {
                    "retina": {
                        "web": "/uploads/reports/category/1/markers/retina_web_valid_report_category_marker.png",
                        "mobile": "/uploads/reports/category/1/markers/retina_mobile_valid_report_category_marker.png"
                    },
                    "default": {
                        "web": "/uploads/reports/category/1/markers/default_web_valid_report_category_marker.png",
                        "mobile": "/uploads/reports/category/1/markers/default_mobile_valid_report_category_marker.png"
                    }
                },
                "color": "#f3f3f3",
                "resolution_time": null,
                "user_response_time": null,
                "allows_arbitrary_position": false,
                "statuses": [
                    {
                        "id": 1,
                        "title": "Random status 1",
                        "color": "#ff0000",
                        "initial": false,
                        "final": false
                    },
                    {
                        "id": 2,
                        "title": "Initial status",
                        "color": "#ff0000",
                        "initial": true,
                        "final": false
                    },
                    {
                        "id": 3,
                        "title": "Final status",
                        "color": "#ff0000",
                        "initial": false,
                        "final": true
                    }
                ]
            },
            "user": {
                "id": 70,
                "name": "Hans Ratke",
                "email": "harmon_keeling@mcglynn.ca",
                "phone": "11912231545",
                "document": "55330938180",
                "address": "491 Jakubowski Harbor",
                "address_additional": "Suite 345",
                "postal_code": "04005000",
                "district": "Maciburgh",
                "created_at": "2014-02-10T13:14:49.519-02:00"
            },
            "inventory_item": null,
            "created_at": "2014-02-21T16:36:03.215-03:00",
            "updated_at": "2014-02-21T16:36:03.215-03:00"
        }
    }

### Specifying the user at report creation

To specify the user at the creation of the report use `user_id` parameter in the request:

    {
      ...
      'user_id': 123
    }

## Editing a report

__URI__ `PUT /reports/:category_id/items/:id`

### Input parameters

| Name              | Type    | Required   | Description                                                                   |
|-------------------|---------|------------|-------------------------------------------------------------------------------|
| category_id       | Integer | Yes        | Report category id                                                            |
| inventory_item_id | Integer | No         | Inventory item id                                                             |
| latitude          | String  | No         | Report latitude. Will use inventory's if it is not filled.                    |
| longitude         | String  | No         | Report longitude. Will use inventory's if it is not filled.                   |
| description       | String  | No         | Report description                                                            |
| address           | String  | No         | Report full address                                                           |
| reference         | String  | No         | Address reference                                                             |
| number            | String  | No         | Address number                                                                |
| district          | String  | No         | Report district                                                               |
| city              | String  | No         | Report city                                                                   |
| state             | String  | No         | Report state                                                                  |
| country           | String  | No         | Report country                                                                |
| images            | Array   | No         | An array of images, encoded in base64 for this report                         |
| status_id         | Integer | No         | The report status, will use the default initial status of the report category |
| user_id           | Integer | No         | To associate an user with the report                                          |
| confidential      | Boolean | No         | Whether the report is confidential (it is not visible to the citizens)             |


Example of request:

    {
      "description": "Árvore caiu aqui na rua",
    }

Example of response:

    {
        "report": {
            "id": 1824,
            "protocol": 1824000014649690,
            "address": "Rua Abilio Soares, 140",
            "position": {
                "latitude": -23.573474,
                "longitude": -46.643152
            },
            "description": "Árvore caiu aqui na rua",
            "category_icon": {
                "url": "/uploads/reports/category/1/icons/valid_report_category_icon.png",
                "retina": {
                    "url": "/uploads/reports/category/1/icons/retina_valid_report_category_icon.png"
                },
                "default": {
                    "url": "/uploads/reports/category/1/icons/default_valid_report_category_icon.png"
                }
            },
            "inventory_categories": [],
            "images": [],
            "status": {
                "id": 2,
                "title": "Initial status",
                "color": "#ff0000",
                "initial": true,
                "final": false
            },
            "category": {
                "id": 1,
                "title": "Limpeza de Boca",
                "icon": {
                    "retina": {
                        "web": {
                            "active": "/uploads/reports/category/1/icons/retina_web_active_valid_report_category_icon.png",
                            "disabled": "/uploads/reports/category/1/icons/retina_web_disabled_valid_report_category_icon.png"
                        },
                        "mobile": {
                            "active": "/uploads/reports/category/1/icons/retina_mobile_active_valid_report_category_icon.png",
                            "disabled": "/uploads/reports/category/1/icons/retina_mobile_disabled_valid_report_category_icon.png"
                        }
                    },
                    "default": {
                        "web": {
                            "active": "/uploads/reports/category/1/icons/default_web_active_valid_report_category_icon.png",
                            "disabled": "/uploads/reports/category/1/icons/default_web_disabled_valid_report_category_icon.png"
                        },
                        "mobile": {
                            "active": "/uploads/reports/category/1/icons/default_mobile_active_valid_report_category_icon.png",
                            "disabled": "/uploads/reports/category/1/icons/default_mobile_disabled_valid_report_category_icon.png"
                        }
                    }
                },
                "marker": {
                    "retina": {
                        "web": "/uploads/reports/category/1/markers/retina_web_valid_report_category_marker.png",
                        "mobile": "/uploads/reports/category/1/markers/retina_mobile_valid_report_category_marker.png"
                    },
                    "default": {
                        "web": "/uploads/reports/category/1/markers/default_web_valid_report_category_marker.png",
                        "mobile": "/uploads/reports/category/1/markers/default_mobile_valid_report_category_marker.png"
                    }
                },
                "color": "#f3f3f3",
                "resolution_time": null,
                "user_response_time": null,
                "allows_arbitrary_position": false,
                "statuses": [
                    {
                        "id": 1,
                        "title": "Random status 1",
                        "color": "#ff0000",
                        "initial": false,
                        "final": false
                    },
                    {
                        "id": 2,
                        "title": "Initial status",
                        "color": "#ff0000",
                        "initial": true,
                        "final": false
                    },
                    {
                        "id": 3,
                        "title": "Final status",
                        "color": "#ff0000",
                        "initial": false,
                        "final": true
                    }
                ]
            },
            "user": {
                "id": 70,
                "name": "Hans Ratke",
                "email": "harmon_keeling@mcglynn.ca",
                "phone": "11912231545",
                "document": "55330938180",
                "address": "491 Jakubowski Harbor",
                "address_additional": "Suite 345",
                "postal_code": "04005000",
                "district": "Maciburgh",
                "created_at": "2014-02-10T13:14:49.519-02:00"
            },
            "inventory_item": null,
            "created_at": "2014-02-21T16:36:03.215-03:00",
            "updated_at": "2014-02-21T16:39:58.995-03:00"
        }
    }

### Updating a report image

To update a report image you can pass `images` parameter in the body of the request in the following format:

    {
      "images": [{
        "id": 1,
        "file": "imagem encodada em base64 aqui"
      }]
    }

**Recall that the image must be encoded in Base64 in order for the update to be actually performed.**

### Updating report status

To update the report item status, it is required to pass `status_id` attribute in the request:

    {
      "status_id": 1
    }

The status id must belong to the report category the item belongs to and it must be a valid status.

## Deleting a report

To permanently delete a report, just send a request to:

__URI__ `DELETE /reports/items/:id`


## Visualizing a report item

To visualize information of a report item, pass the parameter `id` of the desired item to the following endpoint:

__URI__ `GET /reports/items/{item_id}`

Example of parameters for the request:

    /reports/items/1

Example of response:

    {
        "report": {
            "id": 1,
            "protocol": null,
            "address": "Some random crap, 20",
            "position": {
                "latitude": -13.12427698396538,
                "longitude": -21.385812899349485
            },
            "description": null,
            "images": [],
            "status": {
                "id": 1,
                "title": "Test",
                "color": "#FFFFFF",
                "initial": true,
                "final": false
            },
            "category": {
                "id": 1,
                "title": "Teste",
                "icon": {
                    "url": "/uploads/map_pin_boca-lobo.png"
                },
                "marker": {
                    "url": "/uploads/map_pin_boca-lobo.png"
                },
                "resolution_time": 13,
                "user_response_time": null,
                "allows_arbitrary_position": false,
                "statuses": [
                    {
                        "id": 2,
                        "title": "Test 2",
                        "color": "#FF0000",
                        "initial": false,
                        "final": true
                    },
                    {
                        "id": 1,
                        "title": "Test",
                        "color": "#FFFFFF",
                        "initial": true,
                        "final": false
                    }
                ]
            },
            "user": {
                "id": 1,
                "name": null,
                "email": "teste@gmail.com",
                "phone": null,
                "document": null,
                "address": null,
                "address_additional": null,
                "postal_code": null,
                "district": null,
                "created_at": "2014-01-12T19:20:29.863-02:00",
                "groups": [
                    {
                        "id": 1,
                        "name": "Administradores",
                        "permissions": {
                            "add_users": "true"
                        },
                        "created_at": "2014-01-26T08:19:30.495-02:00",
                        "updated_at": "2014-01-26T08:19:30.495-02:00"
                    }
                ]
            },
            "inventory_item": null,
            "created_at": "2014-01-12T19:21:59.325-02:00",
            "updated_at": "2014-01-25T21:42:03.942-02:00"
        }
    }



### Visualizing report items by geographical position

You can list report items by geographical position. For this, simply pass the coordinate of the center of the user screen and a distance in meters to the radius around this location. Use the `limit` parameter to control the number of returned items.

Information related to the status must be searched in the listing of the report category shown by `category_id`.

**Warning**: This implementation will be updated as soon as possible to include better screen control and points distribution, follow the issues:

https://ntxdev.atlassian.net/browse/ZUPAPI-81

https://ntxdev.atlassian.net/browse/ZUPAPI-78

__URI__ `GET /reports/items`

__Query string:__

    ?position[latitude]=40.86            Latitude do ponto de origem
    &position[longitude]=-122.03         Longitude do ponto de origem
    &position[distance]=10000            Radio em metros
    &limit=40
    &zoom=18                             O zoom reportado pelo Google Maps

_Note_: The `distance` parameter is interpreted in meters.

The `limit` parameter defines the limit of returned objects to be plotted on the map.

Example of response:

    {
        "reports": [
            {
                "id": 171,
                "protocol": 1710000196684042,
                "address": "Some street",
                "position": {
                    "latitude": -5.9764499019623365,
                    "longitude": -18.572619292478098
                },
                "description": null,
                "images": [],
                "status_id": 1,
                "category_id": 1,
                "inventory_item_id": null,
                "created_at": "2014-01-25T23:37:05.218-02:00",
                "updated_at": "2014-01-25T23:37:05.218-02:00"
            },
            {
                "id": 197184,
                "protocol": 1971840000136235,
                "address": "Some street",
                "position": {
                    "latitude": -6.0398746758553585,
                    "longitude": -18.431211356027262
                },
                "description": null,
                "images": [],
                "status_id": 1,
                "category_id": 1,
                "inventory_item_id": null,
                "created_at": "2014-01-26T04:10:13.882-02:00",
                "updated_at": "2014-01-26T04:10:13.882-02:00"
            }
        ]
    }

#### Search by multiple positions

You can perform searches using multiple points. Pass the query string as follows:

__Query string:__

    ?position[0][latitude]=40.86            Origin point latitude
    &position[0][longitude]=-122.03         Origin point longitude
    &position[0][distance]=10000            Radius in meters
    &position[1][latitude]=40.86
    &position[1][longitude]=-122.03
    &position[1][distance]=10000

    &limit=40
    &zoom=18                             Zoom reported by Google Maps

### Listing reports of a report category

To list reports of a report category, use the following endpoint:

```
GET /reports/{category_id}/items
```

The return is the same as from other listing endpoints.

### Listing reports of a specific user

To list reports of a specific user, use the following endpoint:

```
GET /users/{user_id}/items
```

The return is the same as other listing endpoints.

### Creating a confidential report

To mark a report as confidential, you can pass `confidential` parameter as `true` in the endpoints for creating and updating a report item.

__URI__ `POST /reports/:category_id/items`

    {
      ...
      "confidential": true
    }

## Migrating a category report

To edit a category report, use the following endpoint:

__URI__ `PUT /reports/:category_id/items/:id/change_category`

And pass the following parameters:

    {
      "new_category_id": 2,
      "new_status_id": 3
    }

* `new_category_id` is the id of the new item category
* `new_status_id` is the id of the new status (of the new category) the item should be transferred to
