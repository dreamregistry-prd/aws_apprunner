export TF_VAR_dream_project_dir="$PWD/myapp"
export TF_VAR_domain_prefix=apprunner-demo-app

# Blue-green deployment: uncomment these lines to deploy green version
export TF_VAR_enable_blue_green=true
export TF_VAR_live_version=blue
export TF_VAR_deploy_new_version=false

terraform apply -auto-approve
