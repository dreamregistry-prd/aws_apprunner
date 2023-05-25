export TF_VAR_dream_project_dir="$PWD/myapp"
export TF_VAR_domain_prefix=apprunner-demo-app

terraform init
terraform apply -auto-approve
