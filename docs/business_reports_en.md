# Reports

Two entities are used to create reports: `BusinessReport` and `Chart`.

## Permissions

Two permissions were created to manage reports: `business_reports_edit` and `business_reports_view`.

* `business_reports_edit`: a **boolean** permission that authorizes creation, edition and deletion of reports
* `business_reports_view`: a permission associated to `BusinessReport` ids that authorizes groups to visualize them

## BusinessReport

`BusinessReport` contains report data, such as title, author, summary, etc. Each `BusinessReport` contains graphs of the reports, `Chart`.

### Endpoints

The endpoints to create, edit, visualize and delete reports are a basic CRUD composed by the following endpoints:

    GET /business_reports
    POST /business_reports
    PUT /business_reports/:id
    DELETE /business_reports/:id

To `POST` and `PUT` endpoints the following parameters must be consider:

| Attribute  | Type   | Required | Description                                 |
|------------|--------|----------|---------------------------------------------|
| title      | String | Yes      | Report title                                |
| summary    | String | No       | Short summary of the report                 |
| begin_date | Date   | No       | The initial date for displaying report data |
| end_date   | Date   | No       | The end date for displaying report data     |

## Chart

Each `Chart` is an entity that represents the graphs in a report. After created, a _background job_ is triggered to populate the data of the graph, from which an attribute `data` will be returned.

### Endpoints

The endpoints to create, edit, visualize and delete charts are a basic CRUD composed by the following endpoints:

    GET /business_reports/:id/charts
    POST /business_reports/:id/charts
    PUT /business_reports/:id/charts/:id
    DELETE /business_reports/:id/charts/:id

To `POST` and `PUT` endpoints the following parameters must be consider:
	
| Attribute      | Type           | Required  | Description                                             |
|----------------|----------------|-----------|---------------------------------------------------------|
| metric         | String         | Yes       | The metric that will be used to populate the chart      |
| chart_type     | String         | Yes       | Can be 'pie' or 'line'                                  |
| title          | String         | Yes       | Chart title                                             |
| description    | String         | No        | A chart description that can be shown with the graph    |
| begin_date     | Date           | No        | The initial date for displaying data in the chart       |
| end_date       | Date           | No        | The end date for displaying data in the chart           |
| categories_ids | Array[Integer] | No        | The ids of the categories for filtering data of a graph |

> **Note:** The attributes `begin_date` and `end_date` are required for the entity. They are not required for this endpoint, as it will try to use the parameters `begin_date` and
> `end_date` from the report. If they're empty, a validation error will be returned as well.

Return structure is as below:

    {
      "id": 1,
      "metric": "total-reports-by-category"
      "chart_type": "line",
      "title": "Gráfico de relatos por categoria",
      "description": "Este é um gráfico de linha",
      "data": {
        "content": [
          ["Categoria", "Total"],
          ["Categoria 1", 4590],
          ["Categoria 2", 1231],
          ...
        ]
      }
    }

Note that the chart data corresponding to the selected period will be populated in the attribute `data`. 

### Metrics

The metrics that are available for graphs are:

| Metric                                    | Description                                                      |
|-------------------------------------------|------------------------------------------------------------------|
| total-reports-by-category                 | Total reports created by category                                |
| total-reports-by-status                   | Total reports created by status                                  |
| total-reports-overdue-by-category         | Total overdue reports by category                                |
| total-reports-overdue-by-category-per-day | Total overdue reports by category and by number of days overdue  |
| total-reports-assigned-by-category        | Total associated reports by category                             |
| total-reports-assigned-by-group           | Total associated reports by group                                |
| total-reports-unassigned-to-user          | Total reports not associated with any user                       |
| average-resolution-time-by-category       | Average resolution time by category                              |
| average-resolution-time-by-group          | Average resolution time by associated group                      |
| average-overdue-time-by-category          | Average delay by category                                        |
| average-overdue-time-by-group             | Average delay by group                                           |
