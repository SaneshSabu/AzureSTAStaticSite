
export location="east-us"

set +e; 
terraform plan -var-file=config//${location}.tfvars -out=plan.out -detailed-exitcode; echo \$? > status"
