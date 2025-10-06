resource "azurerm_public_ip" "firewall-pip" {
  name                = "firewallpip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "hubvnet-firewall" {
  name                = "hub-vnet-firewall"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.fwpolicy.id

  ip_configuration {
    name                 = "configurationfw"
    subnet_id            = azurerm_subnet.AzureFirewallSubnet.id
    public_ip_address_id = azurerm_public_ip.firewall-pip.id
  }
}

resource "azurerm_firewall_policy" "fwpolicy" {
  name                = "fw-policy"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  #firewalls           = [azurerm_firewall.hubvnet-firewall.id]

}

resource "azurerm_firewall_policy_rule_collection_group" "hub-fwrule-collection" {
  name               = "hub-fw-rule-collection"
  firewall_policy_id = azurerm_firewall_policy.fwpolicy.id
  priority           = 500

  application_rule_collection {
    name = "app_rule_collection1"

    priority = 200
    action   = "Allow"
    rule {
      name = "AllowAzurePipelines"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses = ["10.1.0.0/23"]

      destination_fqdns = ["azure.microsoft.com", "dev.azure.com"]
    }
  }

  network_rule_collection {
    name     = "AllowDNS"
    priority = 400
    action   = "Allow"
    rule {
      name                  = "AllowDNSRule"
      protocols             = ["UDP"]
      source_addresses      = ["10.1.0.0/23"]
      destination_addresses = ["1.1.1.1", "1.0.0.1"]

      destination_ports = ["53"]
    }
  }


}
