.PHONY: init
init:
	terragrunt init --terragrunt-working-dir bootstrap 
	terragrunt apply -auto-approve --terragrunt-working-dir bootstrap

.PHONY: plan
plan:
	terragrunt plan

.PHONY: apply
apply:
	terragrunt apply

.PHONY: destroy
destroy:
	terragrunt destroy

BUCKET=$(shell aws s3api list-buckets --query "Buckets[?starts_with(Name, 'terraform-state-bucket-')].Name" --output text)

.PHONY: nuke
nuke:
	terragrunt destroy
	@aws s3api delete-objects --bucket $(BUCKET) --delete "$$(aws s3api list-object-versions --bucket $(BUCKET) --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"
	@aws s3api delete-objects --bucket $(BUCKET) --delete "$$(aws s3api list-object-versions --bucket $(BUCKET) --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')"
	terragrunt destroy --terragrunt-working-dir bootstrap
