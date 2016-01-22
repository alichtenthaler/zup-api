# API - Inventory / Categories

## Creating an inventory category

__URI__ `POST /inventory/categories`

__Warning: the post for this endpoint must be in form/multipart format in order to files be uploaded correctly. Do not send as JSON in this case.__

Example of request:

    {
      "title": "árvores",
      "description: "árvores da cidade",
      "plot_format": "pin",
      "icon": (uploaded_file),
      "marker": (uploaded_file)
    }

Example of response:

    {
      "category" : {
        "id" : 3,
        "title" : "Árvores",
        "plot_format": "pin",
        "description" : "Árvores da cidade,
        "created_at" : "2014-01-12T00:51:47.319-02:00",
        "updated_at" : "2014-01-12T00:51:47.319-02:00"
      },
      "message" : "Category created with success"
    }

### Icons, pins, markers

An inventory category can have icons, pins and markers, we will explain the difference between these fields.

Images must be the white pictogram that will enter into the `icon` and markers`. This pictogram you submit will be inserted into other colour images with the colour of the category.

Multiple versions of each are generated, then the return field will always be an object with the various versions.

* `icon` - the category icon, appears in the filters
* `pins` - the ball that is shown on the map with no icon inside, that image is automatically generated so you can send any image
* `markers` - the marker shown on the map with the white icon that you sent in this field.

In short, to create the category you only send the white icon with transparent background that will be inserted in the other base images.

In return, you will receive multiple versions generated for image.

__Warning: These images should be encoded and sent only in base64.__

## Editing a category

__URI__ `PUT /inventory/categories/:id`

Example of request:

    {
      "title": "Árvores",
      "description: "Árvores da cidade",
      "token": "e40678fa7cb48f9fa3a734d202f10b88"
    }

Example of response:

    {
      "category" : {
        "id" : 3,
        "title" : "Árvores",
        "plot_format": "pin",
        "description" : "Árvores da cidade,
        "created_at" : "2014-01-12T00:51:47.319-02:00",
        "updated_at" : "2014-01-12T00:51:47.319-02:00"
      },
      "message" : "Category updated successfully"
    }

## Deleting a category

__URI__ `DELETE /inventory/categories/:id`

Example of response:

    {
      "message": "Category deleted successfully"
    }

## Getting data from a category

__URI__ `GET /inventory/categories/1`

Example of response:

    {
        "category": {
            "id": 1,
            "title": "Random name 1",
            "description": "A cool category",
            "plot_format": "pin",
            "marker": {
                "retina": {
                    "web": "/uploads/inventory/category/1/markers/retina_web_valid_report_category_marker.png",
                    "mobile": "/uploads/inventory/category/1/markers/retina_mobile_valid_report_category_marker.png"
                },
                "default": {
                    "web": "/uploads/inventory/category/1/markers/default_web_valid_report_category_marker.png",
                    "mobile": "/uploads/inventory/category/1/markers/default_mobile_valid_report_category_marker.png"
                }
            },
            "icon": {
                "retina": {
                    "web": {
                        "active": "/uploads/inventory/category/1/icons/retina_web_active_valid_report_category_icon.png",
                        "disabled": "/uploads/inventory/category/1/icons/retina_web_disabled_valid_report_category_icon.png"
                    },
                    "mobile": {
                        "active": "/uploads/inventory/category/1/icons/retina_mobile_active_valid_report_category_icon.png",
                        "disabled": "/uploads/inventory/category/1/icons/retina_mobile_disabled_valid_report_category_icon.png"
                    }
                },
                "default": {
                    "web": {
                        "active": "/uploads/inventory/category/1/icons/default_web_active_valid_report_category_icon.png",
                        "disabled": "/uploads/inventory/category/1/icons/default_web_disabled_valid_report_category_icon.png"
                    },
                    "mobile": {
                        "active": "/uploads/inventory/category/1/icons/default_mobile_active_valid_report_category_icon.png",
                        "disabled": "/uploads/inventory/category/1/icons/default_mobile_disabled_valid_report_category_icon.png"
                    }
                }
            }
        }
    }

You can get more fields passing the `display_type` parameter as `full` on the request:	

`GET /inventory/categories/2?display_type=full`

Example of response:

{
  "sections" : [
    {
      "fields" : [
        {
          "position" : 0,
          "id" : 101,
          "title" : "latitude",
          "label" : "Latitude",
          "kind" : "text"
        },
        ...
      ],
      "id" : 11
    },
    ...
  ],
  "id" : 2,
  "created_at" : "2014-01-11T16:08:57.769-02:00",
  "title" : "Random name 2",
  "description" : "A cool category",
  "updated_at" : "2014-01-11T16:08:57.769-02:00"
}


## Listing categories

__URI__ `GET /inventory/categories`

Example of response:

    {
      "categories" : [
        {
          "id" : 2,
          "title" : "Random name 2",
          "plot_format": "pin",
          "description" : "A cool category",
          "created_at" : "2014-01-11T16:08:57.769-02:00",
          "updated_at" : "2014-01-11T16:08:57.769-02:00"
        },
        {
          "id" : 3,
          "title" : "Cool group",
          "plot_format": "pin",
          "description" : null,
          "created_at" : "2014-01-12T00:51:47.319-02:00",
          "updated_at" : "2014-01-12T00:51:47.319-02:00"
        }
      ]
    }

### With parameters

To perform a search with category title, only send a parameter "title" in the request.

__URI__ `GET /inventory/categories`

Example of request:

    {
      "title": "Cool"
    }

Example of response:

    {
      "categories" : [
        {
          "id" : 2,
          "created_at" : "2014-01-11T16:08:57.769-02:00",
          "title" : "Random name 2",
          "description" : "A cool category",
          "plot_format": "pin",
          "updated_at" : "2014-01-11T16:08:57.769-02:00"
        },
        {
          "id" : 3,
          "created_at" : "2014-01-12T00:51:47.319-02:00",
          "title" : "Cool group",
          "description" : null,
          "plot_format": "pin",
          "updated_at" : "2014-01-12T00:51:47.319-02:00"
        }
      ]
    }

### Paginating

You can make pagination in the list with the following parameters (both optional):

{
  "per_page": 10,
  "page": 2
}

The parameter `per_page` is `25` by default.

## Form creation/update

*Note:* All categories comes with the "Location" section by default.

__URI__ `PUT /inventory/categories/:id/form`

The only required parameter is `sections`, which should be an array of all sections with their respective fields. Follow the structure of the example below.

Example of request:

    {
      "sections": [{
        "title": "Localização",
        "permissions": {},
        "position": 0,
        "fields": [{
          "title": "latitude",
          "kind": "text",
          "size": "M",
          "permissions": {},
          "label": "Latitude",
          "position": 0
        }]
      }
    }

Example of response:

    {
      "message": "Category's form updated successfully"
    }

### Special field types

#### Images

Passing a field as `kind` equal to `imagem`, the content (`content`) assigned to this field should be in array format with images encoded in Base64.

Example of the type field `images`:

    {
      ...
      "fields": [{
        "title": "imagens",
        "kind": "images",
        "permissions": {},
        "label": "Imagens",
        "position": 0
      }]
      ...
    }

When creating an item for this field, the attribute `content` should be an array of encoded images.

### Deleting section or form field

To delete a section or a field, just send an attribute `destroy` in your JSON, example:

    // This section will be destroyed
    // You can do the same thing in "fields"
    {
      "sections": [{
        "id": 1234,
        "destroy": true,
        "title": "Localização",
        "permissions": {},
        "position": 0,
        "fields": [{
          "title": "latitude",
          "kind": "text",
          "size": "M",
          "permissions": {},
          "label": "Latitude",
          "position": 0
        }]
      }
    }

## 'Lock' in category form editing

To lock the editing of the category form, you should make a request to the following endpoint:

`PATCH /inventory/categories/:id/update_access`

After 1 minute, the category is automatically unlocked if not received this `heartbeat` anymore, thus, the request should be made with a frequency less than 60 seconds.
