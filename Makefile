test:
	mix test

start-db:
	docker run --name stairs_postgres -p 5432:5432 -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres -d postgres

stop-db:
	docker stop stairs_postgres

run:
	mix phx.server

format:
	mix format
