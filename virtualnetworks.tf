
#Virtual network
resource "azurerm_network_security_group" "master_nsg" {
  name                = "master-security-group"
  location            = azurerm_resource_group.learnings.location
  resource_group_name = azurerm_resource_group.learnings.name

  /* security_rule {
    name                       = "http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  } */
}

resource "azurerm_virtual_network" "master" {
  name                = "master-network"
  location            = azurerm_resource_group.learnings.location
  resource_group_name = azurerm_resource_group.learnings.name
  address_space       = [var.virtual_network_settings.master.vnet_cidr]
  tags = {
    environment = "Develop"
  }
}

resource "azurerm_subnet" "public_subnet" {
  name                 = "master-public"
  resource_group_name  = azurerm_resource_group.learnings.name
  virtual_network_name = azurerm_virtual_network.master.name
  address_prefixes     = [cidrsubnet(var.virtual_network_settings.master.vnet_cidr, 8, 0)]
}
resource "azurerm_subnet" "private_subnet" {
  name                 = "master-private"
  resource_group_name  = azurerm_resource_group.learnings.name
  virtual_network_name = azurerm_virtual_network.master.name
  address_prefixes     = [cidrsubnet(var.virtual_network_settings.master.vnet_cidr, 8, 1)]
}
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.learnings.name
  virtual_network_name = azurerm_virtual_network.master.name
  address_prefixes     = [cidrsubnet(var.virtual_network_settings.master.vnet_cidr, 10, 10)]
}

#Subnet association with NSG

resource "azurerm_subnet_network_security_group_association" "nsglink0" {
  subnet_id                 = azurerm_subnet.public_subnet.id
  network_security_group_id = azurerm_network_security_group.master_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "nsglink1" {
  subnet_id                 = azurerm_subnet.private_subnet.id
  network_security_group_id = azurerm_network_security_group.master_nsg.id
}
#Bastion host configuration

resource "azurerm_public_ip" "bastionip" {
  name                = "bastion-ip"
  location            = azurerm_resource_group.learnings.location
  resource_group_name = azurerm_resource_group.learnings.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "qb-bastion" {
  name                = "qb-bastion"
  location            = azurerm_resource_group.learnings.location
  resource_group_name = azurerm_resource_group.learnings.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastionip.id
  }
}

#Network Security rule for allow ssh from bastion

resource "azurerm_network_security_rule" "bastion_ssh" {
  name                        = "allow-ssh-from-bastion"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = azurerm_public_ip.bastionip.ip_address
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.learnings.name
  network_security_group_name = azurerm_network_security_group.master_nsg.name
}

resource "azurerm_network_security_rule" "allow_80" {
  name                        = "http-allow-from-vpn"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefixes     = var.whitelisted_ips.test02_vpn
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.learnings.name
  network_security_group_name = azurerm_network_security_group.master_nsg.name
}