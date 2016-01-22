# API: Report Statistics

To consult report statistics, use the following endpoint:

`GET /reports/stats`

Example with parameters:

`/reports/stats?category_id=1`

or as array

`/reports/stats?category_id[]=1&category_id[]=2`

Example of response:

    {
        "stats": [
            {
                "category_id": 1,
                "name": "Limpeza de Boca",
                "statuses": [
                    {
                        "status_id": 3,
                        "title": "Final status",
                        "count": 0
                    },
                    {
                        "status_id": 2,
                        "title": "Initial status",
                        "count": 910
                    },
                    {
                        "status_id": 1,
                        "title": "Random status 1",
                        "count": 0
                    }
                ]
            }
        ]
    }


## Filtering by date

You can filter by date passing the parameters `begin_date` and/or `end_date` in the ISO-8601 format.
