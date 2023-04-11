
# Create a Storage Account for Document root

resource "azurerm_storage_account" "docroot-sta" {
  depends_on                    = [azurerm_resource_group.learnings]
  name                          = var.sta_config.sta_name
  resource_group_name           = azurerm_resource_group.learnings.name
  location                      = azurerm_resource_group.learnings.location
  account_kind                  = var.sta_config.account_kind
  account_tier                  = var.sta_config.account_tier
  access_tier                   = var.sta_config.access_tier
  account_replication_type      = var.sta_config.account_replication_type
  enable_https_traffic_only     = true
  public_network_access_enabled = true
  #public_network_access_enabled = false

  # network_rules {

  #   private_link_access {
  #     endpoint_resource_id = azurerm_private_endpoint.pvt-endpoint.id
  #   }

  # }
  routing {
    choice = "MicrosoftRouting"
  }
}

# Create a Storage Container for Document root

resource "azurerm_storage_container" "docroot-container" {
  #depends_on            = [azurerm_storage_account.imagegalary-sta]
  name                  = var.sta_config.container_name
  storage_account_name  = azurerm_storage_account.docroot-sta.name
  container_access_type = "container"
}

# End point creation for private access to the blob

resource "azurerm_private_endpoint" "pvt-endpoint" {
  name                = "docroot-endpoint"
  location            = azurerm_resource_group.learnings.location
  resource_group_name = azurerm_resource_group.learnings.name
  subnet_id           = azurerm_subnet.private_subnet.id
  private_dns_zone_group {
    name                 = "docRoot"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns-zone.id]

  }

  private_service_connection {
    name                           = "docroot-privateserviceconnection"
    private_connection_resource_id = azurerm_storage_account.docroot-sta.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
  depends_on = [azurerm_private_dns_zone.dns-zone]
}

# Create Private DNS Zone

resource "azurerm_private_dns_zone" "dns-zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.learnings.name
}

# Create Private DNS Zone Network Link

resource "azurerm_private_dns_zone_virtual_network_link" "network_link" {
  name                  = "docroot-nw-lnk"
  resource_group_name   = azurerm_resource_group.learnings.name
  private_dns_zone_name = azurerm_private_dns_zone.dns-zone.name
  virtual_network_id    = azurerm_virtual_network.master.id
}

# Create DNS A Record

resource "azurerm_private_dns_a_record" "dns_a" {
  name                = "docroot-dns-record"
  zone_name           = azurerm_private_dns_zone.dns-zone.name
  resource_group_name = azurerm_resource_group.learnings.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.pvt-endpoint.private_service_connection.0.private_ip_address]
}

# Adding Service Role To Access Storage Account by the VM

resource "azurerm_role_assignment" "blob_contributor" {
  scope                = azurerm_storage_account.docroot-sta.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_virtual_machine.web_server_vm.identity[0].principal_id
  #condition = "((!(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read'}) AND !(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write'})))"
  #condition_version = "2.0"
}
