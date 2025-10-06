resource "azurerm_resource_group" "rg" {

  location = var.resource_group_location
  name     = var.resource_group_name

  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "app-vnet-vnet" {
  name                = "app-vnet"
  address_space       = [var.PrefixAddress-Vnet]
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags = {
    environment = "dev"
  }

}

resource "azurerm_virtual_network" "hub-vnet-vnet" {
  name                = "hub-vnet"
  address_space       = [var.PrefixAddress-hubVnet]
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags = {
    environment = "dev"
  }

}


resource "azurerm_subnet" "frontendsubnet" {
  name                 = var.frontsubnet-nVnet
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.app-vnet-vnet.name
  address_prefixes     = var.PrefixAddress-frontend


}

resource "azurerm_subnet" "backendsubnet" {
  name                 = var.backendsubnet-nVnet
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.app-vnet-vnet.name
  address_prefixes     = var.PrefixAddress-backend

}

resource "azurerm_subnet" "AzureFirewallSubnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet-vnet.name
  address_prefixes     = var.PrefixAddress-firewallSubnet

}



# resource "azurerm_virtual_network_peering" "peer1" {
#  name                      = "peer1"
#  resource_group_name       = azurerm_resource_group.rg.name
#  virtual_network_name      = azurerm_virtual_network.app-vnet-vnet.name
#  remote_virtual_network_id = azurerm_virtual_network.hub-vnet-vnet.id
#  allow_forwarded_traffic   = true
#  allow_gateway_transit     = false

#}

module "peering" {
  source = "../modules/peering"

  name                                 = "app-to-hub"
  parent_id                            = azurerm_virtual_network.app-vnet-vnet.id
  remote_virtual_network_id            = azurerm_virtual_network.hub-vnet-vnet.id
  allow_forwarded_traffic              = true
  allow_gateway_transit                = true
  allow_virtual_network_access         = true
  create_reverse_peering               = true
  reverse_allow_forwarded_traffic      = false
  reverse_allow_gateway_transit        = false
  reverse_allow_virtual_network_access = true
  reverse_name                         = "hub-to-app-vnet"
  reverse_use_remote_gateways          = false
  use_remote_gateways                  = false
}

resource "azurerm_application_security_group" "zenithHealth-frontendasg" {
  name                = "app-frontend-asg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    Hello = "World"
  }
}

resource "azurerm_application_security_group" "zenithHealth-backend-asg" {
  name                = "app-backend-asg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    Hello = "World"
  }
}

# Create a Network Security Group
resource "azurerm_network_security_group" "appfrontend-nsg" {
  name                = "app-frontend-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name


  security_rule = [{
    access                                     = "Allow"
    description                                = "Test zenithhealth nsg"
    destination_address_prefix                 = null
    destination_address_prefixes               = null
    destination_application_security_group_ids = [azurerm_application_security_group.zenithHealth-frontendasg.id]
    destination_port_range                     = "22"
    destination_port_ranges                    = null
    direction                                  = "Inbound"
    name                                       = "allowssh"
    priority                                   = 1011
    protocol                                   = "Tcp"
    source_address_prefix                      = "*"
    source_address_prefixes                    = null
    source_application_security_group_ids      = null
    source_port_ranges                         = null
    source_port_range                          = "*"

    }, {
    access                                     = "Allow"
    description                                = "Test1"
    destination_address_prefix                 = null
    destination_address_prefixes               = null
    destination_application_security_group_ids = [azurerm_application_security_group.zenithHealth-frontendasg.id]
    destination_port_range                     = "443"
    destination_port_ranges                    = null
    direction                                  = "Inbound"
    name                                       = "testHttpsMultiple"
    priority                                   = 1001
    protocol                                   = "Tcp"
    source_address_prefix                      = "*"
    source_address_prefixes                    = null
    source_application_security_group_ids      = null
    source_port_ranges                         = null
    source_port_range                          = "*"
  }]

}

# Associate the Subnet with the Network Security Group
resource "azurerm_subnet_network_security_group_association" "app-frontend-nsg-association" {
  subnet_id                 = azurerm_subnet.frontendsubnet.id
  network_security_group_id = azurerm_network_security_group.appfrontend-nsg.id
}

resource "azurerm_network_security_group" "appbackend-nsg" {
  name                = "app-backend-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule = [{
    access                                     = "Allow"
    description                                = ""
    destination_address_prefix                 = "*"
    destination_address_prefixes               = []
    destination_application_security_group_ids = []
    destination_port_range                     = "22"
    destination_port_ranges                    = []
    direction                                  = "Inbound"
    name                                       = "allowsshforbackendrule"
    priority                                   = 100
    protocol                                   = "Tcp"
    source_address_prefix                      = ""
    source_address_prefixes                    = []
    source_application_security_group_ids      = [azurerm_application_security_group.zenithHealth-frontendasg.id]
    source_port_range                          = "*"
    source_port_ranges                         = []
  }]

}

resource "azurerm_subnet_network_security_group_association" "app-backend-nsg-association" {
  subnet_id                 = azurerm_subnet.backendsubnet.id
  network_security_group_id = azurerm_network_security_group.appbackend-nsg.id
}


resource "azurerm_route_table" "zenith-route_table" {
  name                = "hub-vnet-firewall-rt"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  route {
    name                   = "route-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.hubvnet-firewall.ip_configuration[0].private_ip_address #zenithHealth-firewall.ip_configuration[0].private_ip_address

  }
}

resource "azurerm_subnet_route_table_association" "frontendsubnet-route_table_association" {
  subnet_id      = azurerm_subnet.frontendsubnet.id
  route_table_id = azurerm_route_table.zenith-route_table.id
}

resource "azurerm_subnet_route_table_association" "backendsubnet-route_table_association" {
  subnet_id      = azurerm_subnet.backendsubnet.id
  route_table_id = azurerm_route_table.zenith-route_table.id
}
