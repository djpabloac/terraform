terraform {

  # Configurar backend
  backend "azurerm" {
    resource_group_name  = "minuevorg"
    storage_account_name = "storageminuevorg"
    container_name       = "intermediominuevorg"
    key                  = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.43.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~>4.0"
    }
  }
}

provider "azurerm" {
  features {}
}
