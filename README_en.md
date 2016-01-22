# Participatory Urban Janitorial - API

## Introduction
It is known that information handling is crucial for an efficient management and that is why Participatory Urban Janitorial(or ZUP) features a full life historic of each of the assets and of municipal problems, incorporating citizens' requests, geo-referenced data, technical reports, photographs and preventive actions taken over time. This way, the system centralizes all the information, allowing authorities and field technicians to take rapid decisions.

This component is the basis of ZUP's information processing, acting as the end point of consumption of all components involved in the product:

* Android and iOS application for citizens
* Web application for citizens
* Android application for inventory management
* Web admin panel

## Technologies
ZUP-API is a project written in RUBY that uses several components and libraries.

## Installation
**NOTE:** This README teaches you how to deploy the project in a development environment. For information on how to deploy the project in production, see the Installation Guide
[Guia de instalação](http://docs.zup.ntxdev.com.br/site/installation_docker/).

To install ZUP for development on your machine, you will require:
* Postgres 9.4+
* Postgis 2.1+
* ImageMagick 6.8+
* Redis 2.8.9
* Ruby 2.2.1
* GEOS

## Install the libraries
After installing these dependencies, let's install the libraries. Run the following command on the root of your project:

	bundle install

## Environment setup
After installing the libraries, set the environment variables for the application to work properly.

By opening the file `sample.env` file on the root of the project, you have access to all environment variables available for the configuration of the project. Copy this file to the root of the project with the name .env and fill at least the mandatory variables required for the component to work:

* `API_URL` - Complete URL at which the API will answer (include the port if it is not port 80)
* `SMTP_ADDRESS` - SMTP server address for email sending
* `SMTP_PORT` - SMTP server port
* `SMTP_USER` - User for SMTP authentication
* `SMTP_PASS` - Password for SMTP authentication
* `SMTP_TTLS` - TTLS configuration for SMTP
* `SMTP_AUTH` - Configuration of SMTP authentication mode
* `REDIS_URL` - URL where Redis server is listening to (eg.: redis://10.0.0.1:6379)
* `WEB_URL` - Complete URL where ZUP-PAINEL component is running

## Database initial setup

After setting the environment variables in the .env file, you are ready to configure database.

First, copy the file `config/database.yml.sample` to `config/database.yml` and change it with the data from your Postgres.

Once this is done, perform database setup:

    rake db:setup

**At the end of this command an user and an administrator password are generated. Keep them in a safe location, as you will need them to log in to the system for the first time.**

To start the server, you just need to run the following command:

    bundle exec foreman start -f Procfile.dev

If everything is ok, this should be your output:

```
12:05:22 web.1    | started with pid 63360
12:05:22 worker.1 | started with pid 63361
12:05:23 web.1    | =============== Phusion Passenger Standalone web server started ===============
12:05:23 web.1    | PID file: /Users/user/projects/zup-api/passenger.3000.pid
12:05:23 web.1    | Log file: /Users/user/projects/zup-api/log/passenger.3000.log
12:05:23 web.1    | Environment: development
12:05:23 web.1    | Accessible via: http://0.0.0.0:3000/
12:05:23 web.1    |
12:05:23 web.1    | You can stop Phusion Passenger Standalone by pressing Ctrl-C.
12:05:23 web.1    | Problems? Check https://www.phusionpassenger.com/library/admin/standalone/troubleshooting/
12:05:23 web.1    | ===============================================================================
12:05:25 web.1    | App 63391 stdout:
12:05:29 worker.1 | /Users/user/projects/zup-api/lib/mapquest.rb:6: warning: already initialized constant Mapquest::API_ROOT
12:05:29 worker.1 | /Users/user/projects/zup-api/lib/mapquest.rb:6: warning: previous definition of API_ROOT was here
12:05:29 worker.1 | 2015-09-23T15:05:29.390Z 63361 TID-owtng2518 INFO: Booting Sidekiq 3.4.2 with redis options {:url=>"redis://127.0.0.1:6379", :namespace=>"zup"}
12:05:29 worker.1 | 2015-09-23T15:05:29.431Z 63361 TID-owtng2518 INFO: Cron Jobs - add job with name: unlock_inventory_items
12:05:29 worker.1 | 2015-09-23T15:05:29.437Z 63361 TID-owtng2518 INFO: Cron Jobs - add job with name: set_reports_overdue
12:05:29 worker.1 | 2015-09-23T15:05:29.443Z 63361 TID-owtng2518 INFO: Cron Jobs - add job with name: expire_access_keys
12:05:29 worker.1 | 2015-09-23T15:05:29.454Z 63361 TID-owtng2518 INFO: Running in ruby 2.2.1p85 (2015-02-26 revision 49769) [x86_64-darwin14]
12:05:29 worker.1 | 2015-09-23T15:05:29.454Z 63361 TID-owtng2518 INFO: See LICENSE and the LGPL-3.0 for licensing details.
12:05:29 worker.1 | 2015-09-23T15:05:29.454Z 63361 TID-owtng2518 INFO: Upgrade to Sidekiq Pro for more features and support: http://sidekiq.org/pro
12:05:29 worker.1 | 2015-09-23T15:05:29.454Z 63361 TID-owtng2518 INFO: Starting processing, hit Ctrl-C to stop
12:05:30 web.1    | App 63391 stderr: /Users/user/projects/zup-api/lib/mapquest.rb:6: warning: already initialized constant Mapquest::API_ROOT
12:05:30 web.1    | App 63391 stderr: /Users/user/projects/zup-api/lib/mapquest.rb:6: warning: previous definition of API_ROOT was here
12:05:31 web.1    | App 63411 stdout:
```

You can access the following URL to make sure the server is running properly:

[](http://127.0.0.1:3000/feature_flags)

It's done! For more information on the internal components of the API, read the documents in the `docs/` folder which can be found in the root of the project.




