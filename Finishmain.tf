terraform {

    required_providers {
        azurerm = {
            version = "~> 3.0"
        }
    }
}

provider "azurerm" {
    features{}
    subscription_id = "f0f630bb-2329-490f-8139-9073c1314404"
}

    
resource "azurerm_resource_group" "rg" {
    name = var.resource_group_name
    location = var.location
}

#Virtual Network
resource "azurerm_virtual_network" "vnet" {
    name = "my-vnet" 
    location = var.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = ["10.0.0.0/16"]
}

    #Subnet
    resource "azurerm_subnet" "AzSN" {
    name = "tf_subnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name =  azurerm_virtual_network.vnet.name
    address_prefixes = ["10.0.1.0/24"]
}

    resource "azurerm_subnet" "private_endpoint" {
    name = "azurerm_endpoint"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.0.2.0/24"]
}
    resource "azurerm_subnet" "subnet_aks" {
        name = "subnet_aks"
        resource_group_name = azurerm_resource_group.rg.name
        virtual_network_name = azurerm_virtual_network.vnet.name
        address_prefixes = ["10.0.3.0/24"]
    }
resource "azurerm_network_security_group" "nsg" {
    name = "webapp-nsg" 
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
#HTTP
    security_rule {
        name  = "Allow-HTTP"
    priority  = 100
    direction  = "Inbound" 
    access = "Allow" 
    protocol = "Tcp"
    source_port_range  = "*"
    destination_port_range = "80"
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
    source_port_range = "*"
    destination_port_range = "443"
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
    source_port_range = "*"
    destination_port_range ="3389"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    }
}

    #Associate NSG to Subnet

    resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
    network_interface_id = azurerm_network_interface.AzNIC.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}
    resource "azurerm_network_interface" "AzNIC" {
        name = "NIC"
        location = azurerm_resource_group.rg.location
        resource_group_name = azurerm_resource_group.rg.name
        ip_configuration {
            name                          = "internal"
            subnet_id                     = azurerm_subnet.AzSN.id
            private_ip_address_allocation = "Dynamic"
  }
}


#Public IP for Load Balancer
resource "azurerm_lb" "lb_public_ip" {
    name = "lb_public_ip"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

    #Public IP
    resource "azurerm_public_ip" "AzPIP" {
        name = "AzPIP" 
        location = var.location
        resource_group_name = azurerm_resource_group.rg.name
        allocation_method = "Static"
        sku = "Standard"
}

#Virtual Machine
resource "azurerm_windows_virtual_machine" "azurerm-VM" {
    name = "my-vm"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    size = "Standard_DC1ds_v3"
    network_interface_ids = [azurerm_network_interface.AzNIC.id]
    admin_username = var.admin_username
    admin_password = var.admin_password

    os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter-gensecond"
    version   = "latest"
  }
}

