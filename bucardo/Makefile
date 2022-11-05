up: down
	docker-compose run --rm data
	docker-compose up bucardo

pgbench:
	docker-compose up pgbench

down:
	-docker-compose down

client:
	docker-compose run --rm client /bin/bash
