# Parear [![CircleCI](https://circleci.com/gh/vrcca/parear.svg?style=svg&circle-token=1a66b447e2082897e62001bb6e8cd17197e75dac)](https://circleci.com/gh/vrcca/parear)

Reactive pair stairs with reminders.

## Running the app
1. Install Elixir 1.8+ and a compatible version of Erlang
2. Install NodeJS >= 5.0.0
3. Setup all the dependencies with `make`
4. You need Postgres 9.2 running locally. See below how to do it.
5. Run the app with `make run`
6. Access it at https://localhost:4000/

## Setting up the database
You need to setup the Postgres database in localhost:5432.

1. Install docker
2. Run `make start-db`
3. Migrate the database with `make migrations`
