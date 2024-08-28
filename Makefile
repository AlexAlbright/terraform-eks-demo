TARGET_ENV=test
CLUSTER_NAME=test_cluster

.PHONY: init
init:
	terragrunt init --terragrunt-working-dir live/$(TARGET_ENV)/bootstrap 
	terragrunt apply -auto-approve --terragrunt-working-dir live/$(TARGET_ENV)/bootstrap

.PHONY: vpc
vpc:
	terragrunt init --terragrunt-working-dir live/$(TARGET_ENV)/vpc
	terragrunt apply -auto-approve --terragrunt-working-dir live/$(TARGET_ENV)/vpc

.PHONY: eks
eks:
	terragrunt init --terragrunt-working-dir live/$(TARGET_ENV)/eks
	terragrunt apply -auto-approve --terragrunt-working-dir live/$(TARGET_ENV)/eks
	aws eks update-kubeconfig --region us-east-1 --name $(CLUSTER_NAME)
	kubectl set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true
	terragrunt apply -auto-approve -replace="module.eks.module.eks_managed_node_group[\"default\"].aws_eks_node_group.this[0]" --terragrunt-working-dir live/$(TARGET_ENV)/eks

.PHONY: helm
helm:
	terragrunt init --terragrunt-working-dir live/$(TARGET_ENV)/helm
	terragrunt apply -auto-approve -terragrunt-working-dir live/$(TARGET_ENV)/helm

.PHONY: cluster
cluster: init vpc eks helm

BUCKET=$(shell aws s3api list-buckets --query "Buckets[?starts_with(Name, 'terraform-state-bucket-')].Name" --output text)

.PHONY: nuke
nuke:
	terragrunt destroy
	@aws s3api delete-objects --bucket $(BUCKET) --delete "$$(aws s3api list-object-versions --bucket $(BUCKET) --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"
	@aws s3api delete-objects --bucket $(BUCKET) --delete "$$(aws s3api list-object-versions --bucket $(BUCKET) --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')"
	terragrunt destroy --terragrunt-working-dir bootstrap
