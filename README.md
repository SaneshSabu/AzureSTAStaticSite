# LVMH-exercise-infra

---

### Description
```
Terraform script to build a base infra that includes static websites hosted in nginx on azure cloud platform.
```
----
## Prerequisite
- Need to install Terraform
- Azure CLI with latest version - https://learn.microsoft.com/en-us/cli/azure/get-started-with-azure-cli
-----

### Azure CLI installation steps

```sh
##Get packages needed for the install process

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
sudo apt-get update
sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg

##Download and install the Microsoft signing key

sudo mkdir -p /etc/apt/keyrings

curl -sLS https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/microsoft.gpg

#Add the Azure CLI software repository:

AZ_REPO=$(lsb_release -cs)
echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
    sudo tee /etc/apt/sources.list.d/azure-cli.list

##Update repository information and install the azure-cli package

sudo apt-get update
sudo apt-get install azure-cli -y
```

#### Download AzCopy tool to copy the contents to blobstorage.
```sh
wget https://aka.ms/downloadazcopy-v10-linux

#Expand Archive
tar -xvf downloadazcopy-v10-linux

#Move AzCopy to the destination you want to store it
sudo cp ./azcopy_linux_amd64_*/azcopy /usr/bin/

# az login
sudo az login --identity
sudo azcopy login --identity

# For Uploading websites contents to STA
sudo azcopy copy "<file/DIR>" "https://storageacctname.blob.core.windows.net/container-name/" --recursive=true
```
#### To validate and verify the Terraform code
```sh
./dev-tools/validate/validate.sh
```
#### To apply the Terraform code
```sh
terraform apply -var-file=config/east-us.tfvars
```
#### To use SSH to connect to the virtual machine, do the following steps:
##### Run terraform output to get the SSH private key and save it to a file.
```sh
terraform output -raw tls_private_key > id_rsa
```
