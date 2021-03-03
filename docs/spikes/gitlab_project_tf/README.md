# Gitlab Project via Terraform

https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs

## Getting Started

### Set up Environment Variables

* `export GITLAB_TOKEN='<GIT_LAB_TOKEN>'`
* `export GITLAB_BASE_URL='<GIT_LAB_SERVER_ROOT_URL>/api/v4/'`

### Deploy Project

* `terraform plan -out=plan.tfplan`
* `terraform apply "plan.tfplan`

--