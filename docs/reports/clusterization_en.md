# Report Clustering

Use the endpoint `GET /search/reports/items` to request for the clustered version when searching in the map. To do so, just pass `clusterize: true` in the parameters:

    ...
    &clusterize=true

## Return

When you pass this parameter, the response JSON to be returned will have a different structure:

    {
      "clusters": [...]
      "reports": [...]
    }

### Clusters

**clusters** are simpler entities that represent a set of reports and its attributes are as follows:

    {
      "items_ids": [1, 2, 3],
      "position": [-23.5546875, -46.636962890625],
      "category_id": 2, // ID da categoria de relato
      "count": 3
    }

* `items_ids` are the reports ids being represented
* `position` are the geographical coordinates of the report categories
* `category_id` the report category id
* `count` is the number of inventory items being represented by the cluster

> * Depending on the zoom level, the API may or may not group more than one category in the same cluster. When this happens, it will be returned the `categories_ids` parameter instead of `category_id`