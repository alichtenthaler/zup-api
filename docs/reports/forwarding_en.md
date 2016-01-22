# Forwarding reports

ZUP supports a functionality for report forwarding. To enable this feature, new functionalities and endpoints were added to the API.

## Permissions

There are 4 new permissions:

* `reports_items_forward` - Group can forward the assigned category report item
* `reports_items_create_internal_comment` - Group can insert an internal note into the assigned category reports
* `reports_items_alter_status` - Group can change the report status of the assigned category
* `reports_items_create_comment` - Group can add public or private comment into the assigned category reports

## Endpoints

### Forward report to group

Endpoint:

    PUT '/reports/:category_id/items/:id/forward'

Parameters:

| Parameter | Type    | Required   | Description                                    |
|-----------|---------|------------|------------------------------------------------|
| group_id  | Integer | Yes        | Group id to forward the report to              |
| comment   | String  | No*        | Internal observation to be added to the report |

* The `comment` is required if the flag `comment_required_when_forwarding` of the report category is active.

### Associate report to user

Endpoint:

    PUT '/reports/:category_id/items/:id/assign'

Parameters:

| Parameter | Type    | Required   | Description                       |
|-----------|---------|------------|-----------------------------------|
| user_id   | Integer | Yes        | Group id to forward the report to |

### Edit status of a report

Endpoint:

    PUT '/reports/:category_id/items/:id/update_status'

Parameters:

| Parameter          | Type    | Required   | Description                                    |
|--------------------|---------|------------|------------------------------------------------|
| status_id          | Integer | Yes        | Id of the new status for the report            |
| comment            | String  | No*        | Comment to be added to the report              |
| comment_visibility | Integer | No**       | Comment visibility, 0 = Public and 1 = Private |

* `comment` is required if the flag `comment_required_when_updating_status` of the report category is active.
** The `comment_visibility` is required if `comment` is present.

## Flags

Two new flags were added to the report category:

* `comment_required_when_forwarding` - An internal comment is required when forwarding a report
* `comment_required_when_updating_status` - A public or private comment is required when updating a report

These flags can be passed to the endpoints of creation and edition of report category.

## Historic

There are two new historic types for report items: `forward` and `user_assign`.

These two new types can be used to search for entries in the report history.

## Solver groups

For each report category, you can register solver groups that are responsible for the reports. To do so, the attribute `solver_groups_ids` was created, in which the ids of the solvers groups are saved.

Along with that, it was created another attribute called `default_solver_group_id`, in which the default group for which a report is firstly forwarded to is saved

Both attributes can be passed as parameters in the existing endpoints fro creating and editing report categories.

Recall that a standard solver group must be selected if any group is registered as solver in the category.

## Filters

Two new filters were created to improve user experience in navigation, and they can be passed as parameters to the endpoint for report searching (`/search/reports/items`):

### assigned_to_my_group

When passing this parameter as `true` in the request, the search will only return reports associated with solver groups the user belongs to.

### assigned_to_me

When passing this parameter as `true` in the request, the search will only return reports associated with the user logged in.
