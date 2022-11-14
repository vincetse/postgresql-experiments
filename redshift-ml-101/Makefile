region = us-east-1
aws = aws --region $(region)
cf = $(aws) cloudformation
rs = $(aws) redshift
sm = $(aws) sagemaker
s3 = $(aws) s3

cluster_name = demo
database_name = db
port = 8192
cluster_type = single-node
node_type = dc2.large
number_of_nodes = 1
user = dba
password := $(shell echo $${RANDOM} | shasum | awk '{print $$1}')Z
project_name_tag = postgresql-experiments/redshift-ml-101
account_id = $(shell aws sts get-caller-identity --query 'Account' --output text)

# this is the prefix used by Redshift ML for SageMaker job names
sm_jobname_prefix = redshiftml-20221108153611008088
sm_jobname_prefix = redshiftml-20221108

# used by Redshift ML for scratch space and output
ml_bucket_name = redshiftml-$(account_id)

# macros that probably should not be messed with
TEMPLATE = --template-body file://stack.yml
STACK_NAME = redshift-ml-101
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
		--capabilities CAPABILITY_NAMED_IAM
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
		--capabilities CAPABILITY_NAMED_IAM
	$(cf) wait stack-create-complete $(STACK)

delete:
	-$(s3) rm s3://$(ml_bucket_name)/ --recursive
	$(cf) delete-stack $(STACK)
	$(cf) wait stack-delete-complete $(STACK)

describe:
	$(rs) describe-clusters \
		--cluster-identifier $(cluster_name)

################################################################################
# Redshift ML creates a bunch of artifacts in SageMaker that we should clean
# up after we are done with the experiment.
################################################################################
clean: _clean-sm-models _clean-sm-artifacts _clean-sm-contexts _clean-sm-experiments
	rm -f .env

_clean-sm-models:
	$(eval models = $(shell $(sm) list-models --query "Models[].ModelName" --output text))
	for model in $(models); do \
		$(sm) delete-model --model-name $${model}; \
	done

_clean-sm-artifacts:
	$(eval artifacts = $(shell $(sm) list-artifacts --query "ArtifactSummaries[?starts_with(Source.SourceUri, 's3://$(ml_bucket_name)')].ArtifactArn" --output text))
	for artifact in $(artifacts); do \
		source_arns=`$(sm) list-associations --destination-arn $${artifact} --query "AssociationSummaries[].SourceArn" --output text`; \
		for source_arn in $${source_arns}; do \
			$(sm) delete-association --source-arn $${source_arn} --destination-arn $${artifact}; \
		done; \
		destination_arns=`$(sm) list-associations --source-arn $${artifact} --query "AssociationSummaries[].DestinationArn" --output text`; \
		for destination_arn in $${destination_arns}; do \
			$(sm) delete-association --destination-arn $${destination_arn} --source-arn $${artifact}; \
		done; \
		$(sm) delete-artifact --artifact-arn $${artifact}; \
	done

_clean-sm-contexts:
	$(eval arns = $(shell $(sm) list-contexts --query "ContextSummaries[].ContextArn" --output text))
	for arn in $(arns); do \
		source_arns=`$(sm) list-associations --destination-arn $${arn} --query "AssociationSummaries[].SourceArn" --output text`; \
		for source_arn in $${source_arns}; do \
			$(sm) delete-association --source-arn $${source_arn} --destination-arn $${arn}; \
		done; \
	done
	$(eval contexts = $(shell $(sm) list-contexts --query "ContextSummaries[].ContextName" --output text))
	for context in $(contexts); do \
		$(sm) delete-context --context-name $${context}; \
	done

_clean-sm-experiments:
	$(eval experments = $(shell $(sm) list-experiments --query "ExperimentSummaries[?starts_with(ExperimentName,'$(sm_jobname_prefix)')].ExperimentName" --output text))
	for experiment in $(experments); do \
		trials=`$(sm) list-trials --experiment-name $${experiment} --query "TrialSummaries[].TrialName" --output text`; \
		for trial in $${trials}; do \
			components=`$(sm) list-trial-components --trial-name $${trial} --query "TrialComponentSummaries[].TrialComponentName" --output text`; \
			for component in $${components}; do \
			  $(sm) disassociate-trial-component --trial-component-name $${component} --trial-name $${trial}; \
			done; \
		done; \
	done
	for experiment in $(experments); do \
		trials=`$(sm) list-trials --experiment-name $${experiment} --query "TrialSummaries[].TrialName" --output text`; \
		for trial in $${trials}; do \
			components=`$(sm) list-trial-components --trial-name $${trial} --query "TrialComponentSummaries[].TrialComponentName" --output text`; \
			for component in $${components}; do \
				$(sm) delete-trial-component --trial-component-name $${component}; \
			done; \
			$(sm) delete-trial --trial-name $${trial}; \
		done; \
		$(sm) delete-experiment --experiment-name $${experiment}; \
	done
	$(eval components=$(shell $(sm) list-trial-components --query "TrialComponentSummaries[?starts_with(TrialComponentName, '$(sm_jobname_prefix)')].TrialComponentName" --output text))
	for component in $(components); do \
		$(sm) delete-trial-component --trial-component-name $${component}; \
	done
