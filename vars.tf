variable "location" {
  type        = string
  description = "Azure location"
}
variable "resource_group" {
  type        = string
  description = "Azure resource group"
}
variable "virtual_network_settings" {
  description = "CIDR informations of VPC's and its subnets"
}

variable "whitelisted_ips" {
  type        = map(any)
  description = "Whitelisted IPs"
}

variable "sta_config" {

  type        = map(any)
  description = "storage account configurations"

}

variable "vm_configurations" {
  description = "OS informations of VM and its components"
}
