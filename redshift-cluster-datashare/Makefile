region = us-east-1
account_id = $(shell aws sts get-caller-identity --query 'Account' --output text)
aws = aws --region $(region)
cf = $(aws) cloudformation
rs = $(aws) redshift
rss = $(aws) redshift-serverless
ec2 = $(aws) ec2

user = dba
password := $(shell echo $${RANDOM} | shasum | awk '{print $$1}')Z
producer_name = producerv2
consumer_name = consumerv2
datashare_name = demo
project_name_tag = postgresql-experiments/redshift-cluster-datashare

TEMPLATE = --template-body file://stack.yml
STACK_NAME = redshift-cluster-datashare4
STACK = --stack-name $(STACK_NAME)
PARAMETERS = --parameters \
	ParameterKey=ProducerName,ParameterValue=$(producer_name) \
	ParameterKey=ConsumerName,ParameterValue=$(consumer_name) \
	ParameterKey=AdminUsername,ParameterValue=$(user) \
	ParameterKey=AdminUserPassword,ParameterValue=$(password) \
	ParameterKey=ProjectTag,ParameterValue=$(project_name_tag)
TAGS = --tags \
	Key=x-project,Value=$(project_name_tag)

validate:
	$(cf) validate-template $(TEMPLATE)

create: _create _env

_create: validate
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
	$(eval producer_host = $(shell $(rs) describe-clusters \
		--cluster-identifier $(producer_name) --query "Clusters[0].Endpoint.Address" --output text))
	$(eval consumer_host = $(shell $(rss) get-workgroup \
		--workgroup-name $(consumer_name) \
		--query "workgroup.endpoint.address" \
		--output text \
	))
	$(eval port = 5439)
	@echo PGUSER=$(user) > .env
	@echo PGPASSWORD=$(password) >> .env
	@echo PRODUCER_PGHOST=$(producer_host) >> .env
	@echo CONSUMER_PGHOST=$(consumer_host) >> .env
	@echo PGPORT=$(port) >> .env
	@echo PRODUCER_PGDATABASE=producer >> .env
	@echo CONSUMER_PGDATABASE=consumer >> .env

################################################################################
# Set up the datashares
################################################################################
_get_namespace_ids:
	$(eval producer_namespace_arn = $(shell $(rs) describe-clusters \
		--cluster-identifier $(producer_name) --query "Clusters[0].ClusterNamespaceArn" --output text))
	$(eval producer_namespace_id = $(subst arn:aws:redshift:$(region):$(account_id):namespace:,,$(producer_namespace_arn)))
	$(eval consumer_namespace_id = $(shell $(rss) get-namespace \
		--namespace-name $(consumer_name)  --query "namespace.namespaceId" --output text))

datashare: _get_namespace_ids
	-docker-compose run producer-setup psql --command="DROP DATASHARE $(datashare_name);"
	docker-compose run producer-setup psql --command="CREATE DATASHARE $(datashare_name) SET PUBLICACCESSIBLE true; ALTER DATASHARE $(datashare_name) ADD SCHEMA public; ALTER DATASHARE $(datashare_name) ADD ALL TABLES IN SCHEMA public;"
	docker-compose run producer-setup psql -x --command="DESC DATASHARE $(datashare_name); SHOW DATASHARES;"
	docker-compose run producer-setup psql --command="GRANT USAGE ON DATASHARE $(datashare_name) TO NAMESPACE '$(consumer_namespace_id)';"
	-docker-compose run consumer psql --command="DROP DATABASE producer;"
	docker-compose run consumer psql --command="CREATE DATABASE producer FROM DATASHARE $(datashare_name) OF NAMESPACE '$(producer_namespace_id)';"

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
