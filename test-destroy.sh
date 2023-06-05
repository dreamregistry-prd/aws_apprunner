# Run with: dream run -tDp -- bash test-destroy.sh

export TF_VAR_dream_project_dir="$PWD/myapp"
export TF_VAR_domain_prefix=apprunner-demo-app
#export TF_VAR_use_apex_domain=true

terraform destroy -auto-approve
