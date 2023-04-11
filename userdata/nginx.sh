#!/bin/bash

# Install az-cli

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
sudo apt-get install zip -y

# Install Nginx

sudo apt install nginx -y
systemctl start nginx.services
systemctl enable nginx.services

# Clone Site data

wget https://www.tooplate.com/zip-templates/2129_crispy_kitchen.zip
unzip 2129_crispy_kitchen.zip
rm -rf 2129_crispy_kitchen.zip

#Download AzCopy

wget https://aka.ms/downloadazcopy-v10-linux
 
#Expand Archive

tar -xvf downloadazcopy-v10-linux
 
#Move AzCopy to the destination you want to store it

sudo cp ./azcopy_linux_amd64_*/azcopy /usr/bin/


# az login

sudo az login --identity
sudo azcopy login --identity


# Uploading files to STA
sudo azcopy copy "2129_crispy_kitchen/*" "https://${STA_NAME}.blob.core.windows.net/${CONTAINER_NAME}/" --recursive=true
rm -rf 2129_crispy_kitchen

# Create a new server block

cat > /etc/nginx/sites-available/qbazure.com << 'EOF'
server {
  listen 80;
  server_name qbazure.com;

        location / {
        proxy_set_header Host ${STA_NAME}.blob.core.windows.net;
        rewrite ^/(.*) /${CONTAINER_NAME}/index.html break;
        proxy_pass https://${STA_NAME}.blob.core.windows.net/${CONTAINER_NAME};
    }
        location ~ /(.+\.(css|js|woff2|woff|ttf|eot|png|jpg|mp4)) {
        proxy_set_header    Host ${STA_NAME}.blob.core.windows.net;
        rewrite ^/(.*) /${CONTAINER_NAME}/$1/$2/$3 break;
        proxy_pass      https://${STA_NAME}.blob.core.windows.net/${CONTAINER_NAME}/$1;
  }
}
EOF

sudo rm -rf /etc/nginx/sites-enabled/default

# Enable the new server block
ln -s /etc/nginx/sites-available/qbazure.com /etc/nginx/sites-enabled/qbazure.com
sudo systemctl restart nginx