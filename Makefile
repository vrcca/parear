test: test-parear test-repository test-text-client

start-db:
	docker run --name stairs_postgres -p 5432:5432 -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres -d postgres

stop-db:
	docker stop stairs_postgres

test-parear:
	cd parear; mix test; cd -

test-repository:
	cd repository; mix test; cd -

test-text-client:
	cd text_client; mix test; cd -

run-text-client:
	$(MAKE) start-db; cd text_client; mix start; cd -
