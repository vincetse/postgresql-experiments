region = us-east-1
aws = aws --region $(region)
cf = $(aws) cloudformation
rss = $(aws) redshift-serverless
ec2 = $(aws) ec2

workgroup_name = demo
namespace_name = team
database_name = db
base_capacity = 32
user = dba
password := $(shell echo $${RANDOM} | shasum | awk '{print $$1}')Z
project_name_tag = postgresql-experiments/redshift-serverless-101

TEMPLATE = --template-body file://stack.yml
STACK_NAME = redshift-sls-demo
STACK = --stack-name $(STACK_NAME)
PARAMETERS = --parameters \
	ParameterKey=NamespaceName,ParameterValue=$(namespace_name) \
	ParameterKey=WorkgroupName,ParameterValue=$(workgroup_name) \
	ParameterKey=AdminUsername,ParameterValue=$(user) \
	ParameterKey=AdminUserPassword,ParameterValue=$(password) \
	ParameterKey=DatabaseName,ParameterValue=$(database_name) \
	ParameterKey=BaseCapacity,ParameterValue=$(base_capacity)

validate:
	$(cf) validate-template $(TEMPLATE)

create: _create _env

_create: _credentials validate
	$(cf) create-stack $(STACK) $(TEMPLATE) \
		$(PARAMETERS)
	$(cf) wait stack-create-complete $(STACK)

delete:
	$(cf) delete-stack $(STACK)
	$(cf) wait stack-delete-complete $(STACK)

_credentials:
	@echo master user: $(user)
	@echo master password: $(password)

_env:
	$(eval host = $(shell $(rss) get-workgroup \
		--workgroup-name $(workgroup_name) \
		--query "workgroup.endpoint.address" \
		--output text \
	))
	$(eval port = 5439)
	@echo PGUSER=$(user) > .env
	@echo PGPASSWORD=$(password) >> .env
	@echo PGHOST=$(host) >> .env
	@echo PGPORT=$(port) >> .env


__create: _credentials _create _create_wait
	#$(eval host = $(shell $(rs) describe-clusters --cluster-identifier $(cluster_name) --query "Clusters[0].Endpoint.Address" --output text))
	#@echo PGUSER=$(user) > .env
	#@echo PGPASSWORD=$(password) >> .env
	#@echo PGHOST=$(host) >> .env
	#@echo PGPORT=$(port) >> .env

# Add my IP to security group ingress
_get_my_ip:
	$(eval ip = $(shell curl -s -4 https://ifconfig.me))

sg: _get_my_ip
	-$(ec2) authorize-security-group-ingress \
		--group-name default \
		--protocol tcp \
		--port $(port) \
		--cidr $(ip)/32
