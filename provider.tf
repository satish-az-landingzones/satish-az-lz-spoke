# Configure Terraform to set the required AzureRM provider
# version and features{} block.

terraform {
  cloud {
    organization = "tf-az-landingzone"

    workspaces {
      name = "tf-workspace-az-spoke"
    }
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.74.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
  }
}

provider "azurerm" {
  features {}
}