# FGA Expenses Tracker demo

This is a demo application that shows how one can implement fine-grained authorization using [OpenFGA](https://openfga.dev/) into their applications.

## Prerequisites

- Ruby 3.2.2
- Yarn
- Docker
- [OpenFGA CLI](https://github.com/openfga/cli)

## Setup

Clone the repo and:

```bash
# Install JS dependencies
yarn

# Install gems
bundle install

# Seed the database
rake db:schema:load
rake db:seed
```

### Auth0 credentials

The application integrates with [Auth0](https://auth0.com) for authentication. Provide the application with your Auth0 credentials by copying `.env.example` to a new file called `.env` and providing the values:

| Value                 | Description                                  |
| --------------------- | -------------------------------------------- |
| `AUTH0_DOMAIN`        | Your Auth0 domain, e.g: 'myapp.us.auth0.com' |
| `AUTH0_CLIENT_ID`     | Your Auth0 client ID                         |
| `AUTH0_CLIENT_SECRET` | Your Auth0 client secret                     |

### FGA setup

The application provides a [Docker Compose](https://docs.docker.com/compose/reference/) file that allows you to get FGA up and running quickly. Once you have [Docker](https://www.docker.com/) installed, run `docker compose up -d` to start the FGA server.

Next, install the [OpenFGA CLI](https://github.com/openfga/cli) from GitHub. This can be used to interact with the FGA store.

To set up FGA for this application, create a store:

```bash
fga store create --name expenses-tracker
```

This will provide you with a store ID in the JSON output from that command. Copy this value into your `.env` file:

```
FGA_STORE_ID=<your store ID>
```

Next, write the authorization model that is included with this application, providing the ID of the store you just created:

```
fga model write --store-id=<your store ID> --file=config/expenses.fga
```

This time, the output will contain a _model ID_ that you must also include in your `.env` file:

```
FGA_MODEL_ID=<your model ID>
```

Now the application is ready to go 🎉!
