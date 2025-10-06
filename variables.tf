variable "resource_group_location" {
  type        = string
  default     = "francecentral"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  type        = string
  default     = "rg-Configure-secure-access-to-workloads"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "PrefixAddress-Vnet" {
  type        = string
  default     = "10.1.0.0/16"
  description = "Address prefix for the app and hub virtual networks."
}

variable "PrefixAddress-hubVnet" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Address prefix for the app and hub virtual networks."
}

variable "frontsubnet-nVnet" {
  type        = string
  default     = "frontend"
  description = "app frontend subnet name."
}

variable "backendsubnet-nVnet" {
  type        = string
  default     = "backend"
  description = "app backend subnet name."
}

variable "PrefixAddress-frontend" {
  type        = list(string)
  default     = ["10.1.0.0/24"]
  description = "Address prefix for the app frontend subnet."
}
variable "PrefixAddress-backend" {
  type        = list(string)
  default     = ["10.1.1.0/24"]
  description = "Address prefix for the app backend subnet."
}

variable "PrefixAddress-firewallSubnet" {
  type        = list(string)
  default     = ["10.0.0.0/26"]
  description = "Address prefix for the firewall subnet."
}

variable "username" {
  type        = string
  description = "The username for the local account that will be created on the new VM."
  default     = "adminuser"
}



variable "adminPassword" {
  type        = string
  description = "The admin password."
  default     = "Password1234!"
}

variable "vmSize" {
  type        = string
  description = "size of the virtual machine"
  default     = "Standard_DS1_v2"
}
