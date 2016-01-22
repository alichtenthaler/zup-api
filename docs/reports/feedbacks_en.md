# Endpoint for feedback reports

At the end of a report, the user has some time to give a feedback on the treatment of that report.

## Getting the feedback associated with the report

If there is a feedback associated with the report you can obtain it through the endpoint:

    GET /reports/:id/feedback

Example of return

    {
      "feedback": {
        "id": 1,
        "kind": "positive",
        "content": "Tudo foi arrumado!",
        "user": {
          "name": "Alejandrin Muller",
          "groups": [
            {
              "id": 1,
              "name": "P\u00fablico",
              "permissions": {
                "view_sections": "true",
                "view_categories": "true"
              },
              "created_at": "2014-03-08T10:41:07.696-03:00",
              "updated_at": "2014-03-08T10:41:07.696-03:00",
              "guest": true
            },
            {
              "id": 2,
              "name": "Admins",
              "permissions": {
                "manage_users": "true",
                "manage_groups": "true",
                "manage_reports": "true",
                "manage_inventory_items": "true",
                "manage_reports_categories": "true",
                "manage_inventory_categories": "true"
              },
              "created_at": "2014-03-08T10:41:07.750-03:00",
              "updated_at": "2014-03-08T10:41:07.750-03:00",
              "guest": false
            }
          ]
        },
        "images": []
      }
    }

## Creating a feedback

You can only create a feedback if the user's feedback time has not yet expired (`user_response_time` of the report category)

Endpoint:

    POST /reports/:id/feedback

Example of return:

    {
      "feedback": {
        "id": 1,
        "kind": "positive",
        "content": "Tudo foi arrumado!",
        "user": {
          "name": "Alejandrin Muller",
          "groups": [
            {
              "id": 1,
              "name": "P\u00fablico",
              "permissions": {
                "view_sections": "true",
                "view_categories": "true"
              },
              "created_at": "2014-03-08T10:41:07.696-03:00",
              "updated_at": "2014-03-08T10:41:07.696-03:00",
              "guest": true
            },
            {
              "id": 2,
              "name": "Admins",
              "permissions": {
                "manage_users": "true",
                "manage_groups": "true",
                "manage_reports": "true",
                "manage_inventory_items": "true",
                "manage_reports_categories": "true",
                "manage_inventory_categories": "true"
              },
              "created_at": "2014-03-08T10:41:07.750-03:00",
              "updated_at": "2014-03-08T10:41:07.750-03:00",
              "guest": false
            }
          ]
        },
        "images": []
      }
    }
