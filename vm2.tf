variable "prefix2" {
  default = "tfvmex2"
}

resource "azurerm_network_interface" "vm2-nic" {
  name                = "${var.prefix2}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "testconfiguration2"
    subnet_id                     = azurerm_subnet.backendsubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

/*
resource "azurerm_public_ip" "vm2-pip" {
  name                = "examplePublicIP2"
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

resource "azurerm_network_interface" "netinterface2-public" {
  name                = "public-nic2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "publicIPConfiguration2"
    subnet_id                     = azurerm_subnet.backendsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm2-pip.id
  }


}
*/


resource "azurerm_virtual_machine" "vm02" {
  name                = "vm2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [
    azurerm_network_interface.vm2-nic.id
  ]
  vm_size = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "VM-backend"
    admin_username = "adminuser"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}


resource "azurerm_network_interface_application_security_group_association" "zenithHealth-backendasg-assoc" {
  application_security_group_id = azurerm_application_security_group.zenithHealth-backend-asg.id
  network_interface_id          = azurerm_network_interface.vm2-nic.id
}
