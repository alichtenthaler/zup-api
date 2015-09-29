# ZUP-API

[ ![Codeship Status for panchodev/zup-api](https://codeship.com/projects/5e1d56e0-4b3d-0132-ba3a-3e5cf71b5945/status?branch=master)](https://codeship.com/projects/46692)

# Requirements

* Postgres 9.4+
* Postgis 2.1+
* ImageMagick
* Redis 2.8.9
* Ruby 2.2.1
* GEOS

# Project setup without Docker

To setup the project, you need to do the following steps in order:

## Environment setup

You can notice the `sample.env` file that needs to be copied to `.env` file. You need to fill some env vars for the correct functioning of this project:

* `API_URL` - full URL which the API will be running (include the port)
* `SMTP_ADDRESS` - SMTP server address
* `SMTP_PORT` - SMTP server port
* `SMTP_USER` - SMTP user for authentication
* `SMTP_PASS` - SMTP pass for authentication
* `SMTP_TTLS` - SMTP TTLS settings
* `SMTP_AUTH` - SMTP AUTH configuration
* `REDIS_URL` - Redis server URL
* `WEB_URL` - The URL that will run the `zup-painel` project

## Database setup

After you configured your env variables, let's setup the database.

Copy the `config/database.yml.sample` file to `config/database.yml` and modify it with your Postgres data.

Then run the command to create the databases:

    rake db:create db:schema:load

It will create the databases and load the schema into it.

After that runs the seeding rake task:

    rake db:seed

# Project setup using the Dockerfile

If you have Docker running, let's download and setup it using it:

    docker build . -t zup/api
