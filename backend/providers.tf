terraform {
  required_version = "1.13.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.44.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatenmdtm"
    container_name       = "tfstate"
    key                  = "backend/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
