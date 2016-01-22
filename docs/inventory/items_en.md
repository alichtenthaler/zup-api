# Inventory Items

## Creating an inventory item

`POST /inventory/categories/:id/items`

The creation of an inventory item is made with dynamic parameters. Follow the structure of the request example below.

Suppose we have an __Inventory Category__ with the following structure:

`GET /inventory/categories/1/form`

    {
      "id": 1,
      "title": "Praças",
      "description: "Praças da cidade."
      "sections": [{
        "title": "Nome da praça",
        "permissions": {},
        "position": 0,
        "fields": [{
          "id": 6,
          "title": "nome",
          "kind": "text",
          "size": "M",
          "permissions": {},
          "label": "Nome",
          "position": 0
        }]
      }]
    }

In order to create an item for this category, a valid request example would be:

`POST /inventory/categories/1/items`

    {
      "data": {
        "6": "Praça São Jorge"
      ]
    }

Where `"6"` is the field id (`inventory_field`) and `"Praça São Jorge"` is the content of that field.

An example of response

    {
      "message" : "Item created successfully",
      "item" : {
        "id" : 2,
        "data" : [
          {
            "content" : "Praça São Jorge",
            "field" : {
              "required" : false,
              "position" : 0,
              "id" : 102,
              "created_at" : "2014-01-12T16:36:35.265-02:00",
              "title" : "nome",
              "size" : null,
              "inventory_section_id" : 12,
              "kind" : "text",
              "options" : {
                "size" : "M",
                "label" : "Nome"
              },
              "permissions" : {},
              "updated_at" : "2014-01-12T16:36:35.265-02:00"
            }
          }
        ]
      }
    }

## Fields with choices (kind equal to `checkbox`, `select` and `radio`)

For fields where the user has to choose from a list of options (see `docs/inventory/field_options.md`) the `content` should be the id of the options you want to choose:

    {
      "data": {
        "1": [12, 32]
      }
    }

Where `12` and `32` are the options' ids you want to select for the field.

## Fields with `kind` equal to `images`

For fields of kind `images`, an example of request could be:

    {
      "data": [
        {
          "content": "imagem-encodada-aqui"
        }
      ]
    }

You must pass an __array__ with encoded images in base64.

### Removing an image

To remove an image, you must pass the attribute `destroy` as `true` in the array, as well as the image `id` (returned in the listing of the item)

{
  "data": [
    {
      "id": "123132",
      "destroy": true
    }
  ]
}

You can remove and add images in a single request.

## Editing an item

To edit an inventory item, use the following endpoint:

__URI__ `PUT /inventory/categories/:id/items/:id`

Example of request:

`PUT /inventory/categories/2items/1`

    {
      "data": {
        "6": "Praça São Jorge"
      }
    }

Response:

    {
      "message" : "Item created successfully",
      "item" : {
        "id" : 2,
        "data" : [
          {
            "content" : "Praça São Jorge",
            "field" : {
              "required" : false,
              "position" : 0,
              "id" : 102,
              "created_at" : "2014-01-12T16:36:35.265-02:00",
              "title" : "nome",
              "size" : null,
              "inventory_section_id" : 12,
              "kind" : "text",
              "options" : {
                "size" : "M",
                "label" : "Nome"
              },
              "permissions" : {},
              "updated_at" : "2014-01-12T16:36:35.265-02:00"
            }
          }
        ]
      }
    }

## Listing inventory items

You can list inventory items in two ways:
* Listing the items without categories. For this, do not pass any parameters.
* Filtering by specific field content (when searching by category)

__URI__ `GET /inventory/items`

Example of parameters for the request:

    {
      "filters": [{
        "field_id": 1,
        "content": "Árvor"
      }],
      "inventory_category_id": 2
    }

Example of response:

    {
      "items": [{
        "id" : 2,
        "data" : [{
          "content" : "Árvore da Praça",
          "field" : {
            "required" : false,
            "position" : 0,
            "id" : 102,
            "created_at" : "2014-01-12T16:36:35.265-02:00",
            "title" : "nome",
            "size" : null,
            "inventory_section_id" : 12,
            "kind" : "text",
            "options" : {
              "size" : "M",
              "label" : "Nome"
            },
            "permissions" : {},
            "updated_at" : "2014-01-12T16:36:35.265-02:00"
          }
        }]
      }]
    }


## View an inventory item

You can visualize the information of an inventory item by passing the category `id` and the `id` of the desired item to the following endpoint:

__URI__ `GET /inventory/categories/{category_id}/items/{item_id}`

Example of parameters for the request:

    /inventory/categories/1/items/1

Example of response:

    {
       "item":{
          "id":1,
          "position":{
             "latitude":38.9381545320739,
             "longitude":-73.9212453413708
          },
          "inventory_category_id":1,
          "data":[
             {
                "inventory_field_id":24,
                "content":"Random name 37"
             },
             {
                "inventory_field_id":23,
                "content":"Random name 38"
             },
             {
                "inventory_field_id":22,
                "content":"Random name 39"
             },
             {
                "inventory_field_id":21,
                "content":"Random name 40"
             },
             {
                "inventory_field_id":20,
                "content":"Random name 41"
             }
          ]
       }
    }



### Filtering by geographical position

To enter geographic filters in your query, just pass the coordinate of the centre of the user's screen, and a distance, in meters, to br the radius around this localization. Use the `max_items` parameter to control the number of returned items.

The information related to the fields (found in `data`) must be searched in the inventory category listing indicated by `category_id`.

**Warning**: This implementation will be updated as soon as possible to include better screen control and distribution of points. Follow the issues:

https://ntxdev.atlassian.net/browse/ZUPAPI-81

https://ntxdev.atlassian.net/browse/ZUPAPI-78

__URI__ `GET /inventory/items`

__Query string:__

    ?position[latitude]=40.86            Origin point latitude
    &position[longitude]=-122.03         Origin point longitude
    &position[distance]=10000            Radius in meters
    &limit=40
    &zoom=18                             The zoom reported by Google Maps


_Note_: `distance` parameter must be stated in meters.

`limit` parameter defines the limit of objects to be plotted on the map.


    {
        "items": [
            {
                "id": 42,
                "position": {
                    "latitude": 40.8377346033077,
                    "longitude": -122.078250641083
                },
                "inventory_category_id": 2,
                "data": [
                    {
                        "inventory_field_id": 48,
                        "content": "Random name 1021"
                    },
                    {
                        "inventory_field_id": 47,
                        "content": "Random name 1022"
                    },
                    {
                        "inventory_field_id": 46,
                        "content": "Random name 1023"
                    },
                    {
                        "inventory_field_id": 45,
                        "content": "Random name 1024"
                    }
                ]
            },
            {
               "id":43,
               "position":{
                  "latitude":41.8377346033077,
                  "longitude":-102.078250641083
               },
               "inventory_category_id":2,
               "data":[
                  {
                     "inventory_field_id":48,
                     "content":"Random name 1021"
                  },
                  {
                     "inventory_field_id":47,
                     "content":"Random name 1022"
                  },
                  {
                     "inventory_field_id":46,
                     "content":"Random name 1023"
                  },
                  {
                     "inventory_field_id":45,
                     "content":"Random name 1024"
                  }
               ]
            }
        ]
    }


#### Search for multiple positions

You can perform searches using multiple search points by passing the query string as follows:

__Query string:__

    ?position[0][latitude]=40.86            Latitude do ponto de origem
    &position[0][longitude]=-122.03         Longitude do ponto de origem
    &position[0][distance]=10000            Radio em metros
    &position[1][latitude]=40.86
    &position[1][longitude]=-122.03
    &position[1][distance]=10000

    &limit=40
    &zoom=18                             O zoom reportado pelo Google Maps


#### Displaying the item in the compact form

To display the list of items without the `data` information, pass `display_type` parameter as `basic` on the request  

__Query string:__

    ?display_type=basic

## 'Lock' in inventory item editing

To lock the inventory item edition, you must make a request to the following endpoint:

`PATCH /inventory/categories/:category_id/items/:id/update_access`

After 1 minute, the item is automatically unlocked this`heartbeat` is not received anymore, thus, the request should be made with a frequency less than 60 seconds.
