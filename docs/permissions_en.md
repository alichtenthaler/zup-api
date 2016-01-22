# Permissions

To add (or remove) permissions from a group, use the following endpoint with the group's id:

`PUT /groups/1/permissions`

## Administration permissions 

The following permissions are available for administration.
Their values are boolean (true / false) and it overrides any other group permissions:

```
manage_users
manage_inventory_categories
manage_inventory_items
manage_groups
manage_reports_categories
manage_reports
manage_flows
view_categories
view_sections
```

They can be passed as parameters, e.g.:

    {
      "manage_users": true,
      "manage_groups": false
    }


## Permissions for category sections

Use the following identifiers: `inventory_sections_can_view` and `inventory_sections_can_edit`

Example of request:

    {
      "inventory_sections_can_view": [1,2,3,4],
      "inventory_sections_can_edit": [1,3,4,5]
    }

## Permissions for fields of inventory categories

Use the following identifiers: `inventory_fields_can_view` and `inventory_fields_can_edit`

Example of request:

    {
      "inventory_fields_can_view": [1,2,3,4],
      "inventory_fields_can_edit": [1,4,6,5]
    }
