variable "prefix" {
  default = "tfvmex"
}

resource "azurerm_network_interface" "vm1-nic" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.frontendsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm1-pip.id
  }
}

resource "azurerm_public_ip" "vm1-pip" {
  name                = "examplePublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method = "Static"   # Options: Static or Dynamic
  sku               = "Standard" # Recommended for production workloads
  ip_version        = "IPv4"     # Options: IPv4 or IPv6
  zones             = ["1", "2", "3"]
  tags = {
    environment = "Production"
  }
}

# This is when to add a 2nd NIC
/*
resource "azurerm_network_interface" "netinterface-public" {
  name                = "public-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name = "publicIPConfiguration"
    #subnet_id                     = azurerm_subnet.frontendsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm1-pip.id
  }


}
*/

resource "azurerm_virtual_machine" "vm01" {
  name                = "vm1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [
    azurerm_network_interface.vm1-nic.id
    #,    azurerm_network_interface.netinterface-public.id # This if 2nd NIC is used
  ]
  primary_network_interface_id = azurerm_network_interface.vm1-nic.id
  vm_size                      = var.vmSize

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "VM-frontend"
    admin_username = var.username
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

resource "azurerm_network_interface_application_security_group_association" "zenithHealth-frontendasg-assoc" {
  application_security_group_id = azurerm_application_security_group.zenithHealth-frontendasg.id
  network_interface_id          = azurerm_network_interface.vm1-nic.id
}
