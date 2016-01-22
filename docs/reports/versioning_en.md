# Reports versioning
===

To enable _offline_ synchronization of reports, improvements and increments were made in the API so that reports could be validated against accidental overwriting.

### New column in `reports_items`

Two new columns were created:

* `version` - the version number of the report
* `last_version_at` - date and time of creation of the current version of the report

### Reports modification

In the endpoint `PUT /reports/:category_id/items/:id` a new and optional parameter named `version` was created.

In the case the edition of the report has been made _offline_, the customer must send the parameter `version` updated locally (previous `version` plus 1)

In this case, the endpoint will validate whether the report version agrees or if it has been updated in the meantime.

In the case the report has already been updated and the version that was locally modified is out-of-date, the API will return an error of the type `version_mismatch`, as presented in the example below:

    {
      "type": "version_mismatch",
      "error": "A manipulação do relato é improcedente, nova versão foi inserida no servidor, atualize a sua versão local"
    }
    
In the case the update is ok, which includes the version validation step, the returned status will be `200 OK` and the request body will be of the entity updated in the report. 

**Important remark:** every customer with the edit _offline_ functionality and synchronization must regard and perform the above described manipulations of the parameter `version`. In the future, the parameter `version` will be mandatory for all customers.