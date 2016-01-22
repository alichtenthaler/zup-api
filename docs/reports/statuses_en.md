# Reports status

In order to manipulate report category status, the following endpoints were created:

### Endpoints

* List status
* Create status
* Edit status
* Delete status

## List status

```
GET /reports/categories/:category_id/statuses
```

**Example of return**

```
{
  "statuses": [{
    "active": true,
      "color": "#59B1DF",
      "final": false,
      "id": 10,
      "initial": true,
      "private": false,
      "title": "Em Aberto"
  },
  {
    "active": true,
    "color": "#EACD31",
    "final": false,
    "id": 11,
    "initial": false,
    "private": false,
    "title": "Em Análise Técnica"
  }]
}
```

## Create status

```
POST /reports/categories/:category_id/statuses
```

### Parameters

| Parameter  | Type    | Description                                    |
|------------|---------|------------------------------------------------|
| title*     | String  | Status title                                   |
| color*     | String  | Status color in hexadecimal: #ff0000           |
| initial*   | Boolean | Is the status an initial status?               |
| final*     | Boolean | Is the status a final status?                  |
| private    | Boolean | Defines whether the status is private          |

### Return

**STATUS** 201

```
  {
    "status": {
      "active": true,
      "color": "#59B1DF",
      "final": false,
      "id": 10,
      "initial": true,
      "private": false,
      "title": "Em Aberto"
    }
  }
```

## Edit status

```
PUT /reports/categories/:category_id/statuses/:status_id
```

### Parameters

| Parameter  | Type    | Description                                    |
|------------|---------|------------------------------------------------|
| title      | String  | Status title                                   |
| color      | String  | Status color in hexadecimal: #ff0000           |
| initial    | Boolean | Is the status an initial status?               |
| final      | Boolean | Is the status a final status?                  |
| private    | Boolean | Defines whether the status is private          |

### Return

**STATUS** 200

```
{
  "status": {
    "active": true,
    "color": "#59B1DF",
    "final": false,
    "id": 10,
    "initial": true,
    "private": false,
    "title": "Em Aberto"
  }
}
```

## Delete status

```
DELETE /reports/categories/:category_id/statuses/:status_id
```

### Return

**STATUS** 200

```
{
  "status": {
    "active": true,
    "color": "#59B1DF",
    "final": false,
    "id": 10,
    "initial": true,
    "private": false,
    "title": "Em Aberto"
  }
}
```

> Note: the status is disabled, not deleted
