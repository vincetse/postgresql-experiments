region = us-east-1
aws = aws --region $(region)
cf = $(aws) cloudformation
rs = $(aws) redshift
ec2 = $(aws) ec2

cluster_name = demo
database_name = db
port = 8192
cluster_type = single-node
node_type = dc2.large
number_of_nodes = 1
user = dba
password := $(shell echo $${RANDOM} | shasum | awk '{print $$1}')Z
project_name_tag = postgresql-experiments/redshift-roles-and-default-perms

TEMPLATE = --template-body file://stack.yml
STACK_NAME = redshift-roles-and-default-perms
STACK = --stack-name $(STACK_NAME)
PARAMETERS = --parameters \
	ParameterKey=ClusterIdentifier,ParameterValue=$(cluster_name) \
	ParameterKey=ClusterType,ParameterValue=$(cluster_type) \
	ParameterKey=NodeType,ParameterValue=$(node_type) \
	ParameterKey=NumberOfNodes,ParameterValue=$(number_of_nodes) \
	ParameterKey=Port,ParameterValue=$(port) \
	ParameterKey=MasterUsername,ParameterValue=$(user) \
	ParameterKey=MasterUserPassword,ParameterValue=$(password) \
	ParameterKey=DatabaseName,ParameterValue=$(database_name) \
	ParameterKey=ProjectTag,ParameterValue=$(project_name_tag)

validate:
	$(cf) validate-template $(TEMPLATE)

update: validate
	$(cf) update-stack $(STACK) $(TEMPLATE) \
		$(PARAMETERS) \
		--capabilities CAPABILITY_IAM
	$(cf) wait stack-update-complete $(STACK)

create: _create validate
	$(eval host = $(shell $(rs) describe-clusters --cluster-identifier $(cluster_name) --query "Clusters[0].Endpoint.Address" --output text))
	@echo PGUSER=$(user) > .env
	@echo PGPASSWORD=$(password) >> .env
	@echo PGHOST=$(host) >> .env
	@echo PGPORT=$(port) >> .env

_create:
	$(cf) create-stack $(STACK) $(TEMPLATE) \
		$(PARAMETERS) \
		--capabilities CAPABILITY_IAM
	$(cf) wait stack-create-complete $(STACK)

delete:
	$(cf) delete-stack $(STACK)
	$(cf) wait stack-delete-complete $(STACK)

describe:
	$(rs) describe-clusters \
		--cluster-identifier $(cluster_name)
