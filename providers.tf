terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.45.1"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  subscription_id = "f151ee3f-4725-460d-8e3b-82512dfda843"
  tenant_id       = "6799c70e-3ceb-4e88-af13-8f6c565fd4a5"
  client_id       = "90323805-8d22-46d3-842c-3b991744d1bb"
  client_secret   = "bXJ8Q~P.4qOgedWO_9ARjvc7gz3Pe6CmohgRlcYo"

  resource_provider_registrations = "none"
}
