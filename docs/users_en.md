# API - Users

## Creating an user

To create an user the only required parameters are: `email`, `password` and `password_confirmation`.

Access the page on Swagger-doc to see the other optional parameters.

*Note:* The status code returned from endpoints that create entities in the database is 201 instead of 200.

__URI__ `POST /users`

Example of request:

    {
      "email": "johnk12@gmail.com",
      "password": "astrongpassword",
      "password_confirmation": "astrongpassword"
    }


Example of response:

    {
      "message" : "User created successfully",
      "user" : {
        "id" : 2,
        "password_resetted_at" : null,
        "phone" : null,
        "reset_password_token" : null,
        "address_additional" : null,
        "created_at" : "2014-01-12T03:28:38.576-02:00",
        "address" : null,
        "updated_at" : "2014-01-12T03:28:38.576-02:00",
        "district" : null,
        "postal_code" : null,
        "email" : "johnk12@gmail.com",
        "name" : null,
        "document" : null
      }
    }

## Getting information from an user

__URI__ `GET /users/:id`

Example of request: `GET /users/2`

Example of response:

    {
      "user" : {
        "id" : 2,
        "password_resetted_at" : null,
        "phone" : null,
        "reset_password_token" : null,
        "address_additional" : null,
        "created_at" : "2014-01-12T03:28:38.576-02:00",
        "address" : null,
        "updated_at" : "2014-01-12T03:28:38.576-02:00",
        "district" : null,
        "postal_code" : null,
        "email" : "johnk12@gmail.com",
        "name" : null,
        "document" : null
      }
    }

## Editing information from an user

__URI__ `PUT /users/:id`

Accepts the same parameters as when __creating an user__, but updates an existing user instead.

Example of request:

`PUT /users/2`

    {
      "email": "anotheremail@gmail.com"
    }

Example of response:

    {
      "message": "User updated with success",
      "user": {
        "id" : 2,
        "password_resetted_at" : null,
        "phone" : null,
        "reset_password_token" : null,
        "address_additional" : null,
        "created_at" : "2014-01-12T03:28:38.576-02:00",
        "address" : null,
        "updated_at" : "2014-01-12T03:28:38.576-02:00",
        "district" : null,
        "postal_code" : null,
        "email" : "anotheremail@gmail.com",
        "name" : null,
        "document" : null
      }
    }

### To change a password

To change the password, you must enter the `current_password` attribute with the current password of the referred user.

## Password recovery

You can request a password recovery email through the following endpoint:

__URI__ `PUT /recover_password`

Example of request:

    {
      "email": "user@gmail.com"
    }

Example of response:

    {
      "message": "Password recovery email sent successfully!"
    }

## Password reset

You can reset the user's password by sending `token` (from password recovery) and `new_password` as parameters.

__URI__ `PUT /reset_password`

Example of request:

    {
      "token": "7fefdd79199b9c85fc238b16601ae00e",
      "new_password": "12345"
    }

Example of response:

    {
      "message": "Password changed successfully!"
    }

## Logout

To log out, simply use the endpoint below when logged in:

__URI__ `DELETE /sign_out`

Pass as parameter the __token__ you want to invalidate or do not pass any parameters to invalidate all user access keys.

E.g., invalidating a specific token:

`DELETE /sign_out`

Parameters:

    {
      "token": "asd13s2342bcede4308b1"
    }

## Activating an user

To activate an user, use the following endpoint:

__URI__ `PUT /users/:id/enable`

To use it you need to have permission to manage the users of the particular group the user belongs to.