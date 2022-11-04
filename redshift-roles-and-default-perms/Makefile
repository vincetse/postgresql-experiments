region = us-east-1
aws = aws --region $(region)
rs = $(aws) redshift
ec2 = $(aws) ec2

cluster_name = demo
database_name = db
port = 8192
node_type = dc2.large
user = dba
password := $(shell echo $${RANDOM} | shasum | awk '{print $$1}')Z
cluster_category_tag = default-perms-demo

_credentials:
	@echo master user: $(user)
	@echo master password: $(password)

create: _credentials _create _create_wait
	$(eval host = $(shell $(rs) describe-clusters --cluster-identifier $(cluster_name) --query "Clusters[0].Endpoint.Address" --output text))
	@echo PGUSER=$(user) > .env
	@echo PGPASSWORD=$(password) >> .env
	@echo PGHOST=$(host) >> .env
	@echo PGPORT=$(port) >> .env

_create:
	$(rs) create-cluster \
		--cluster-identifier $(cluster_name) \
		--cluster-type single-node \
		--port $(port) \
		--db-name $(database_name) \
		--node-type $(node_type) \
		--master-username $(user) \
		--master-user-password $(password) \
		--publicly-accessible \
		--preferred-maintenance-window "Mon:12:00-Mon:12:30" \
		--tags Key=x-category,Value=$(cluster_category_tag)

_create_wait:
	while :; do \
		status=$$($(rs) describe-clusters --cluster-identifier $(cluster_name) --query "Clusters[0].ClusterAvailabilityStatus" --output text); \
		if [[ $${status} != "Available" ]]; then \
			sleep 30; \
		else \
			break; \
		fi; \
	done

describe:
	$(rs) describe-clusters \
		--cluster-identifier $(cluster_name)

delete:
	$(rs) delete-cluster \
		--cluster-identifier $(cluster_name) \
		--skip-final-cluster-snapshot
	rm -f .env

# Add my IP to security group ingress
_get_my_ip:
	$(eval ip = $(shell curl -s -4 https://ifconfig.me))

sg: _get_my_ip
	-$(ec2) authorize-security-group-ingress \
		--group-name default \
		--protocol tcp \
		--port $(port) \
		--cidr $(ip)/32
