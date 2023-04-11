# Add variables
location       = "East US"
resource_group = "rg_learnings_423454"



virtual_network_settings = {
  master = {
    vnet_cidr = "10.40.0.0/16"
  }
}

whitelisted_ips = {
  # qb_tvm_ips     = ["202.88.237.207/32", "103.121.27.170/32", "14.98.205.138/32", "112.133.206.230/32", "122.15.225.249/32", "111.93.108.202/32"]
  # qb_clt_ips     = ["111.93.116.30/32", "117.239.250.9/32"]
  # qb_kochi_ips   = ["14.141.33.202/32", "61.12.76.170/32", "115.248.7.141/32", "118.185.82.83/32"]
  # qb_koratty_ips = ["220.225.129.109/32", "14.140.179.22/32", "49.249.171.10/32", "117.239.251.58/32"]
  # fr_vpn_ips     = ["157.107.32.87/32", "222.7.44.153/32", "14.8.12.225/32"]
  test02_vpn = ["54.250.117.192/32"]

}

sta_config = {
  sta_name                 = "qbazure423454"
  container_name           = "qbazure"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  access_tier              = "Hot"
  account_replication_type = "LRS"

}

vm_configurations = {
  vm_values = {
    os_size          = "Standard_DS1_v2"
    os_disk_name     = "myOsDisk"
    os_caching       = "ReadWrite"
    os_storage_type  = "Premium_LRS"
    os_ssh_user      = "devops"
    os_publisher     = "Canonical"
    os_image         = "UbuntuServer"
    os_image_id      = "18_04-lts-gen2"
    os_image_version = "latest"
    os_admin_user    = "devops"
    os_computer_name = "nginx-web"
    vm_name          = "Nginx-VM"
    os_ssh_algorithm = "RSA"
    os_rsa_bits      = "4096"

  }
}