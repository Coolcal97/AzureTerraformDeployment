terraform {
    required_version = ">= 1.5"

    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~> 3.0"
        }
    }
}
 

provider "azurerm" {
    features {}
}

#Azure Resource Group
resource "azurerm_resource_group" "rg" {
    name = var.azure_resource_group 
    location = var.location
}

#Virtual Network
resource "azurerm_virtual_network" "AzVN"{
    name = "Azure_VN" 
    location = "azurerm_resource_group.rg.location"
    resource_group_name = "azurerm_resource_group.rg.name"
    address_space = ["10.0.0.0/16"]
}

#Subnet
resource "azurerm_subnet" "AzSN" {
    name = "tf_subnet"
    resource_group_name = azurerm_resource_group.rg.name
    azurerm_virtual_network = azurerm_resource_group.AzVN.location
    address_space = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
    name = "webapp-nsg" 
    location = azure_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
#HTTP
    security_rule {
        name  = "Allow-HTTP"
    priority  = 100
    direction  = "Inbound" 
    access = "Allow" 
    protocol = "Tcp"
    source_port_range  = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
}

    #HTTPS
security_rule {
    name = "Allow-HTTPS"
    priority = 110
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "443"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    }

    #RDP
security_rule {
    name = "Allow-RDP"
    priority = 120
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "3389"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    }
}

#Associate NSG to Subnet

resource "azurerm_network_security_group_association" "nsg_assoc" {
    Subnet_id = azurerm_subnet.Subnet.Subnet_id
    azurerm_network_security_group_id = azurerm_network_security_group.nsg.id
}

#Public IP for Load Balancer
resource "azure_public_ip_lb" "lb_public_ip" {
    name = "lb_public_ip"
    location = azurerm_resource_group.rg.location
}

#Public IP
resource "azurerm_public_ip" "AzPIP" {
    name = "AzPIP" 
    location = var.location
    resource_group_name = azurerm_resource_group.rg.name
}

#Virtual Machine
resource "azurerm_virtual_machine" "Azure_VM" {
    Name = "Azure_VM"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    size = var.vm_size
    admin_username = var.admin_username
    admin_password = var.admin_password

    network_interface_ids = [
        azure_network_interface.nic.id
    ]

    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "MicrosoftWindowsServer"

    }
}

