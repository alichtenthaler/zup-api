# Inventory Formulas

## Creating a formula for inventory category

To create a formula for a specific inventory category, use the following endpoint:

`POST /inventory/categories/:category_id/formulas`

Example of request:

    {
      "inventory_status_id": 1,
      "groups_to_alert": [1, 3, 4],
      "conditions": [{
        "inventory_field_id": 123,
        "operator": "equal_to",
        "content": "Teste"
      }]
    }

`inventory_status_id` represents category status ID that the item will be set if the conditions of the formula are satisfied.

`groups_to_alert` are the groups of users to be alerted if an item fits the conditions of the formula.

`conditions` is the matrix of conditions the formula contains, its structure is as follows:

`inventory_field_id` => field id which condition will test

`operator` => is the operator used in the condition and may be one of the following:

* equal_to
* greater_than
* lesser_than
* different
* between
* includes

`content` => the content to be tested by the operator. __(can be an array of values)__

### Apply the newly created formula to the category items

To apply the formula to all items in the category, simply pass `"run_formula": true` parameter when creating it.

Example:

    {
      "inventory_status_id": 1,
      "groups_to_alert": [1, 3, 4],
      "conditions": [{
        "inventory_field_id": 123,
        "operator": "equal_to",
        "content": "Teste"
      }],
      "run_formula": true
    }

The formula will be applied to all items, in background.
