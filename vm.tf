
##############################################################
##### Create public IPs
##############################################################

resource "azurerm_public_ip" "web_server_public_ip" {
  name                = "web-server-ip"
  location            = azurerm_resource_group.learnings.location
  resource_group_name = azurerm_resource_group.learnings.name
  allocation_method   = "Dynamic"
}

##############################################################
##### Create network interface
##############################################################

resource "azurerm_network_interface" "web_server_nic" {
  name                = "webNIC"
  location            = azurerm_resource_group.learnings.location
  resource_group_name = azurerm_resource_group.learnings.name

  ip_configuration {
    name                          = "web_nic_configuration"
    subnet_id                     = azurerm_subnet.public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web_server_public_ip.id
  }
}

##############################################################
##### Connect the security group to the network interface
##############################################################
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.web_server_nic.id
  network_security_group_id = azurerm_network_security_group.master_nsg.id
}

##############################################################
###### Create storage account for boot diagnostics
##############################################################
# resource "azurerm_storage_account" "my_storage_account" {
#   name                     = "storageubuntulvmh"
#   location                 = azurerm_resource_group.learnings.location
#   resource_group_name      = azurerm_resource_group.learnings.name
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }

##############################################################
###### Create (and display) an SSH key
##############################################################
resource "tls_private_key" "nginx_ssh" {
  algorithm = var.vm_configurations.vm_values.os_ssh_algorithm
  rsa_bits  = var.vm_configurations.vm_values.os_rsa_bits
}

##############################################################
###### Create virtual machine
##############################################################

resource "azurerm_linux_virtual_machine" "web_server_vm" {
  depends_on            = [azurerm_network_interface.web_server_nic, azurerm_storage_account.docroot-sta]
  name                  = var.vm_configurations.vm_values.vm_name
  location              = azurerm_resource_group.learnings.location
  resource_group_name   = azurerm_resource_group.learnings.name
  network_interface_ids = [azurerm_network_interface.web_server_nic.id]
  size                  = var.vm_configurations.vm_values.os_size

  os_disk {
    name                 = var.vm_configurations.vm_values.os_disk_name
    caching              = var.vm_configurations.vm_values.os_caching
    storage_account_type = var.vm_configurations.vm_values.os_storage_type
  }

  source_image_reference {
    publisher = var.vm_configurations.vm_values.os_publisher
    offer     = var.vm_configurations.vm_values.os_image
    sku       = var.vm_configurations.vm_values.os_image_id
    version   = var.vm_configurations.vm_values.os_image_version
  }

  computer_name                   = var.vm_configurations.vm_values.os_computer_name
  admin_username                  = var.vm_configurations.vm_values.os_admin_user
  disable_password_authentication = true
  custom_data                     = base64encode(data.template_file.userdata_nginx.rendered)

  admin_ssh_key {
    username   = var.vm_configurations.vm_values.os_ssh_user
    public_key = tls_private_key.nginx_ssh.public_key_openssh
  }

  # boot_diagnostics {
  #   storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  # }
  # Adding System Assigned identity
  identity {
    type = "SystemAssigned"
  }


}

##############################################################
###### Template for bootstrapping
##############################################################

data "template_file" "userdata_nginx" {
  template = file("userdata/nginx.sh")
  vars = {
    STA_NAME       = azurerm_storage_account.docroot-sta.name
    CONTAINER_NAME = azurerm_storage_container.docroot-container.name
  }

}


