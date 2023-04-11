#Terraform settings
terraform {
  required_version = ">= 0.12"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.50.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "qurst-tfstate-rg"
    storage_account_name = "qursttf62i3gyru"
    container_name       = "qurst-tfstate"
    key                  = "qburst.tfstate"
  }
}

provider "azurerm" {
  features {}
}


#Creating resource group.

resource "azurerm_resource_group" "learnings" {
  name     = var.resource_group
  location = var.location
}
