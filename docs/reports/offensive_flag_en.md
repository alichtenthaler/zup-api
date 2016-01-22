# Reports tagged as offensive

In order for ZUP to work properly along with the citizens, we have a functionality to tag a report as offensive.

## Tag a report as offensive

#### Endpoint:

    PUT /reports/items/:id/offensive

#### Parameters

None

#### Example of request

    PUT /reports/items/2561/offensive

Return

    {
      "message": "Obrigado por contribuir com a melhoria da sua cidade!"
    }

### Errors

#### User already tagged the report

In case the user has already tagged the report, he/she won't be allowed to tag it again. In this case the API will return an error that must be treated by the customer accordingly to specification.

The request status will be `400` and the return will be a JSON as shown below:

    {
      "type": "model_validation",
      "error": "Você já reportou esse relato!"
    }

#### User exceeded the tag limit for the hour
ZUP limits report tagging to a certain number per hour, defined by the API. In the case this limit is exceeded, the request will return the following error that must be treated by the customer accordingly to specification:

The request status will be `400` and the return will be a JSON as shown below:

    {
      "type": "model_validation",
      "error": "Você já atingiu o limite de reportagem de relatos por hora, aguarde antes de reportar outros relatos."
    }

## Untag report as offensive

For this endpoint, user must have permission to edit the report.

#### Endpoint:

    DELETE /reports/items/:id/offensive

#### Parameters

None

#### Example of request

    DELETE /reports/items/2561/offensive

Return

    {
      "message": "O relato foi marcado como apropriado novamente."
    }
