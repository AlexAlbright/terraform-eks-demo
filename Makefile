.PHONY: init
init:
	terragrunt init --terragrunt-working-dir bootstrap 
	terragrunt apply -auto-approve --terragrunt-working-dir bootstrap

.PHONY: plan
plan:
	terragrunt plan
