terraform fmt --recursive

export location="east-us"
terraform init

terraform validate

terraform plan -var-file=config/${location}.tfvars
