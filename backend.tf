terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "XXXXXXX"
    container_name       = "XXXXXXX"
    key                  = "terraform.XXXXXX"
  }
}
