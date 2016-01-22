# API - Reports Category

## Creating a report category

*URI* `POST /reports/categories`

__WARNING: You must make this request as form/multipart in order to properly upload the files.__

Example of request:

    {
        "title": "A very cool report category",
        "icon": "images/valid_report_category_icon.png",
        "marker": "images/valid_report_category_marker.png",
        "resolution_time": 2 * 60 * 60 * 24,
        "private_resolution_time": false,
        "resolution_time_enabled": true,
        "user_response_time": 1 * 60 * 60 * 24,
        "statuses": [
          0: {"title": "Open", color: "#ff0000", "initial": true, "active": true, "private": false},
          1: {"title": "Closed", color: "#f4f4f4", "final": true, "active": true, "private": false}
        ]
    }

Example of response:

    {
      "category" : {
        "id" : 3,
        "title" : "Árvores",
        "description" : "Árvores da cidade,
        "created_at" : "2014-01-12T00:51:47.319-02:00",
        "updated_at" : "2014-01-12T00:51:47.319-02:00"
      },
      "message" : "Category created with success"
    }

### Creating a private category

To create a private category, pass the `private` parameter as `true`.

    {
      ...
      'private': true
    }

## Editing a report category

*URI* `PUT /reports/categories/:id`

Example of request:

    {
      "title": "Árvores",
      "description: "Árvores da cidade"
    }

Example of response:

    {
      "category" : {
        "id" : 3,
        "title" : "Árvores",
        "description" : "Árvores da cidade,
        "created_at" : "2014-01-12T00:51:47.319-02:00",
        "updated_at" : "2014-01-12T00:51:47.319-02:00"
      },
      "message" : "Category updated successfully"
    }

## Deleting a report category

*URI* `DELETE /reports/categories/:id`

Example of response:

    {
      "message": "Category deleted successfully"
    }

## Listing reports category

*URI* `GET /reports/categories`

Example of response:

    {
        "categories": [
            {
                "id": 2,
                "title": "The 2th report category",
                "icon": {
                    "url": "/uploads/reports/category/2/icons/valid_report_category_icon.png",
                    "retina": {
                        "url": "/uploads/reports/category/2/icons/retina_valid_report_category_icon.png"
                    },
                    "default": {
                        "url": "/uploads/reports/category/2/icons/default_valid_report_category_icon.png"
                    }
                },
                "marker": {
                    "url": "/uploads/reports/category/2/markers/valid_report_category_marker.png",
                    "retina": {
                        "url": "/uploads/reports/category/2/markers/retina_valid_report_category_marker.png"
                    },
                    "default": {
                        "url": "/uploads/reports/category/2/markers/default_valid_report_category_marker.png"
                    }
                },
                "resolution_time": null,
                "user_response_time": null,
                "active": true,
                "allows_arbitrary_position": false,
                "inventory_categories": [],
                "statuses": [
                    {
                        "id": 3,
                        "title": "Final status",
                        "color": "#ff0000",
                        "initial": false,
                        "final": true,
                        "created_at": "2014-01-31T15:05:22.270-02:00",
                        "updated_at": "2014-01-31T15:05:22.270-02:00"
                    },
                    {
                        "id": 2,
                        "title": "Initial status",
                        "color": "#ff0000",
                        "initial": true,
                        "final": false,
                        "created_at": "2014-01-31T15:05:22.263-02:00",
                        "updated_at": "2014-01-31T15:05:22.263-02:00"
                    },
                    {
                        "id": 1,
                        "title": "Random status 1",
                        "color": "#ff0000",
                        "initial": false,
                        "final": false,
                        "created_at": "2014-01-31T15:05:22.235-02:00",
                        "updated_at": "2014-01-31T15:05:22.235-02:00"
                    }
                ],
                "created_at": "2014-01-31T15:05:22.172-02:00",
                "updated_at": "2014-01-31T15:05:22.172-02:00"
            }
        ]
    }


### With parameters

You can view more fields with the `display_type` parameter:

*URI* `GET /reports/categories`

Example of request:

    {
      "display_type": "full"
    }

Example of response:

    {
      "categories": [
          {
              "id": 1,
              "title": "The 1th report category",
              "icon": {
                  "url": "/uploads/valid_report_category_icon.png"
              },
              "marker": {
                  "url": "/uploads/valid_report_category_marker.png"
              },
              "resolution_time": null,
              "user_response_time": null,
              "active": true,
              "allows_arbitrary_position": false,
              "statuses": [],
              "created_at": "2014-01-14T11:44:49.394-02:00",
              "updated_at": "2014-01-14T11:44:49.394-02:00"
          },
          {
              "id": 2,
              "title": "The 2th report category",
              "icon": {
                  "url": "/uploads/valid_report_category_icon.png"
              },
              "marker": {
                  "url": "/uploads/valid_report_category_marker.png"
              },
              "resolution_time": null,
              "user_response_time": null,
              "active": true,
              "allows_arbitrary_position": false,
              "statuses": [],
              "created_at": "2014-01-14T11:44:49.421-02:00",
              "updated_at": "2014-01-14T11:44:49.421-02:00"
          }
          ...
      ]
    }

## Creating subcategories

It is very easy to create a subcategory. When creating a category, just pass in `parent_id` the ID of the category you want to associate the new category with.

    {
      ...
      'parent_id': 123
    }

### Setting a category as confidential

To set a report category as confidential, you can pass the `confidential` parameter as `true` to the endpoints for creating and updating report items.

__URI__ `POST /reports/:category_id`

    {
      ...
      "confidential": true
    }

By doing that, the category's entity will start returning the value `true` for the parameter `confidential`.

## Category resolution time

The category resolution time can be set using the following three attributes:

* `resolution_time_enabled` - whether the resolution time is activated/deactivated for this category
* `resolution_time` - maximum time in seconds an item can remain in the initial status before the a delayed warning occurs
* `private_resolution_time` - whether the resolution time should or not be displayed to the citizens

