terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.44.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "2.7.0"
    }
    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.13.1"
    }
  }
  # backend "azurerm" {
  #   resource_group_name  = "tfstate-rg"
  #   storage_account_name = "tfstatenmdtm"
  #   container_name       = "tfstate"
  #   key                  = "root/envs/dev/terraform.tfstate"
  # }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  subscription_id = var.subscription_id
}

provider "azapi" {
}
