region = us-east-1
aws = aws --region $(region)
cf = $(aws) cloudformation
rss = $(aws) redshift-serverless
ec2 = $(aws) ec2

database_name = db
base_capacity = 32
user = dba
password := $(shell echo $${RANDOM} | shasum | awk '{print $$1}')Z
project_name_tag = postgresql-experiments/redshift-serverless-datashares

TEMPLATE = --template-body file://stack.yml
STACK_NAME = redshift-sls-datashares
STACK = --stack-name $(STACK_NAME)
PARAMETERS = --parameters \
	ParameterKey=AdminUsername,ParameterValue=$(user) \
	ParameterKey=AdminUserPassword,ParameterValue=$(password) \
	ParameterKey=BaseCapacity,ParameterValue=$(base_capacity)
TAGS = --tags \
	Key=x-project,Value=$(project_name_tag)

validate:
	$(cf) validate-template $(TEMPLATE)

create: _create _env

_create: _credentials validate
	$(cf) create-stack $(STACK) $(TEMPLATE) \
		$(PARAMETERS) \
		$(TAGS) \
		--capabilities CAPABILITY_NAMED_IAM
	$(cf) wait stack-create-complete $(STACK)

update: validate
	$(cf) update-stack $(STACK) $(TEMPLATE) \
		$(PARAMETERS) \
		$(TAGS) \
		--capabilities CAPABILITY_NAMED_IAM
	$(cf) wait stack-update-complete $(STACK)

delete:
	$(cf) delete-stack $(STACK)
	rm -f .env
	$(cf) wait stack-delete-complete $(STACK)

################################################################################
# Generate .env file with Redshift credentials
################################################################################
_env:
	$(eval producer_host = $(shell $(rss) get-workgroup \
		--workgroup-name producer \
		--query "workgroup.endpoint.address" \
		--output text \
	))
	$(eval consumer_host = $(shell $(rss) get-workgroup \
		--workgroup-name consumer \
		--query "workgroup.endpoint.address" \
		--output text \
	))
	$(eval port = 5439)
	@echo PGUSER=$(user) > .env
	@echo PGPASSWORD=$(password) >> .env
	@echo PRODUCER_PGHOST=$(producer_host) >> .env
	@echo CONSUMER_PGHOST=$(consumer_host) >> .env
	@echo PGPORT=$(port) >> .env
	@echo PGDATABASE=$(database_name) >> .env

################################################################################
# Set up the datashares
################################################################################
_get_namespace_ids:
	$(eval producer_namespace_id = $(shell $(rss) get-namespace \
		--namespace-name producer --query "namespace.namespaceId" --output text))
	$(eval consumer_namespace_id = $(shell $(rss) get-namespace \
		--namespace-name consumer --query "namespace.namespaceId" --output text))

datashare: _get_namespace_ids
	docker-compose run producer-setup psql --command="GRANT USAGE ON DATASHARE demo TO NAMESPACE '$(consumer_namespace_id)';"
	docker-compose run consumer psql --command="DROP DATABASE producer;"
	docker-compose run consumer psql --command="CREATE DATABASE producer FROM DATASHARE demo OF NAMESPACE '$(producer_namespace_id)';"

################################################################################
# Set up the schema in the producer
################################################################################
producer:
	docker-compose run producer-setup

################################################################################
# Run the consumer script
################################################################################
consumer:
	docker-compose run consumer

################################################################################
# Set up the producer and the datashare, then run select the table from the
# consumer end.
################################################################################
run: producer datashare consumer
