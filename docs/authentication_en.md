# Authentication

The User must be authenticated in the system in order to be able to perform some requests. For this, use the following endpoint:

`POST /authenticate`

### Input parameters

| Name     | Type   | Required    | Description       |
|----------|--------|-------------|-------------------|
| email    | String | Yes         | Account email     |
| password | String | Yes         | Account password  |


Example of request:

    {
      "email": "user@gmail.com",
      "password": "registeredpassword"
    }

Example of response:

    {
      "user": ...,
      "token": "d8068c68c63c8e74310e9dc680063a3f"
    }

**This returned token must be sent in the HEADER of the requests in the following manner: `X-App-Token: token`**
