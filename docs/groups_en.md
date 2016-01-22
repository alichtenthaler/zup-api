API - Groups

# List users of a group

Endpoint: `GET /groups/:id/users`

Example of return:

    {
        "group": {
            "id": 1,
            "name": "Random name 1",
            "permissions": {
                "view_sections": "true",
                "view_categories": "true"
            }
        },
        "users": [
            {
                "id": 72,
                "name": "Jennyfer Schimmel",
                "email": "ewald@lubowitz.biz",
                "phone": "11912231545",
                "document": "43413254189",
                "address": "084 Norval Stream",
                "address_additional": "Suite 063",
                "postal_code": "04005000",
                "district": "New Ian",
                "created_at": "2014-02-02T00:18:15.955-02:00"
            },
            {
                "id": 73,
                "name": "Jennyfer Schimmel",
                "email": "summer.buckridge@okunevalynch.us",
                "phone": "11912231545",
                "document": "43413254189",
                "address": "084 Norval Stream",
                "address_additional": "Suite 063",
                "postal_code": "04005000",
                "district": "New Ian",
                "created_at": "2014-02-02T00:18:16.179-02:00"
            },
            ...
        ]
    }

# Modify permissions of a group

Endpoint: `PUT /groups/:id/permissions`

Example of request:

    {
      "manage_users": true,
      "manage_groups": true,
      "manage_inventory_items": true,
      "manage_reports_items": true
    }

Example of response:

    {
        "group": {
            "id": 1,
            "name": "Random name 1",
            "permissions": {
                "manage_users": true,
                "manage_groups": true,
                "view_sections": "true",
                "view_categories": "true",
                "manage_inventory_items": true
            }
        }
    }

See on Swagger the list of all available methods for groups' permission
