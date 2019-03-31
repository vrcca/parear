test: unit-test integration-test

unit-test:
	mix test

integration-test:
	MIX_ENV=integration mix integration_test

start-db:
	docker run --name stairs_postgres -p 5432:5432 -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres -d postgres

stop-db:
	docker stop stairs_postgres

run:
	mix phx.server

format:
	mix format
