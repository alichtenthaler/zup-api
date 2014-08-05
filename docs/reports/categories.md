# API - Categoria de Relatos

## Criando uma categoria de relato

*URI* `POST /reports/categories`

__ATENÇÃO: Você deve fazer essa requisição como
um form/multipart, para fazer o upload dos arquivos própriamente.__

Exemplo de requisição:

    {
        "title": "A very cool report category",
        "icon": "images/valid_report_category_icon.png",
        "marker": "images/valid_report_category_marker.png",
        "resolution_time": 2 * 60 * 60 * 24,
        "user_response_time": 1 * 60 * 60 * 24,
        "statuses": [
          0: {"title": "Open", color: "#ff0000", "initial": true},
          1: {"title": "Closed", color: "#f4f4f4", "final": true}
        ]
    }

Exemplo de resposta:

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

## Alterando uma categoria de relato

*URI* `PUT /reports/categories/:id`

Exemplo de requisição:

    {
      "title": "Árvores",
      "description: "Árvores da cidade"
    }

Exemplo de resposta:

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

## Deletando uma categoria de relato

*URI* `DELETE /reports/categories/:id`

Exemplo de resposta:

    {
      "message": "Category deleted successfully"
    }

## Listando categorias de relatos

*URI* `GET /reports/categories`

Exemplo de resposta:

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


### Com parâmetros

Você pode exibir mais campos através do parâmetro `display_type`:

*URI* `GET /reports/categories`

Exemplo de requisição:

    {
      "display_type": "full"
    }

Exemplo de resposta:

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
