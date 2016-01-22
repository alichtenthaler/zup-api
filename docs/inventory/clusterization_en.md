# Clustering of Inventory Items

With the endpoint `GET /search/inventory/items` you can ask clustered version when searching by the map. For that, just pass `clusterize: true` in the parameters:

    ...
    &clusterize=true

## Return

When passing this parameter, the JSON in response will have a different structure:

    {
      "clusters": [...]
      "items": [...]
    }

### Clusters

**Clusters** are more simple entities that represent a set of inventory items, its attributes are:

    {
      "items_ids": [1, 2, 3],
      "position": [-23.5546875, -46.636962890625],
      "category_id": 2, // ID da categoria de inventário
      "count": 3
    }

* `items_ids` the ids of inventory items being represented
* `position` the geographical coordinates of reporting categories
* `category_id`* id of inventory category 
* `count` the number of inventory items that the cluster is representing

> * Depending on the zoom level, API can group more than one category in the same cluster. When this happen, `categories_ids` parameter will be returned instead of `category_id`
