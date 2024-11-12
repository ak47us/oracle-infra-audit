# This file creates the Azure Kubernetes clusters

variable "AZURE_SUBSCRIPTION_ID" {}
variable "MY_PUBLIC_IP" {}
provider "azurerm" {
  subscription_id = var.AZURE_SUBSCRIPTION_ID

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

}

resource "azurerm_resource_group" "rg" {
  name     = "main-resource-group"
  location = "Central US"
}

# Clusters:
# resource "azurerm_kubernetes_cluster" "aks_cluster_1" {
#   name                = "aks-cluster-1"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   dns_prefix          = "aks1"
#
#   default_node_pool {
#     name       = "default"
#     node_count = 1
#     vm_size    = "Standard_D2s_v3"
#     vnet_subnet_id = azurerm_subnet.vnet_red_subnet.id
#   }
#
#   identity {
#     type = "SystemAssigned"
#   }
#
#   lifecycle {
#     ignore_changes = [
#       default_node_pool
#     ]
#   }
# }
#
# resource "azurerm_kubernetes_cluster" "aks_cluster_2" {
#   name                = "aks-cluster-2"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   dns_prefix          = "aks2"
#
#   default_node_pool {
#     name       = "default"
#     node_count = 1
#     vm_size    = "Standard_D2s_v3"
#     vnet_subnet_id = azurerm_subnet.vnet_blue_subnet.id
#   }
#
#   identity {
#     type = "SystemAssigned"
#   }
#
#   lifecycle {
#     ignore_changes = [
#       default_node_pool
#     ]
#   }
#
#   network_profile {
#     network_plugin = "azure"
#   }
# }
#
# resource "azurerm_kubernetes_cluster" "aks_cluster_3" {
#   name                = "aks-cluster-3"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   dns_prefix          = "aks3"
#
#   default_node_pool {
#     name       = "default"
#     node_count = 1
#     vm_size    = "Standard_D2s_v3"
#     vnet_subnet_id = azurerm_subnet.vnet_green_subnet.id
#   }
#
#   identity {
#     type = "SystemAssigned"
#   }
#
#   lifecycle {
#     ignore_changes = [
#       default_node_pool
#     ]
#   }
#
#   network_profile {
#     network_plugin = "azure"
#   }
# }

# Networking:
# VNets
resource "azurerm_virtual_network" "red" {
  name                = "vnet-red"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_virtual_network" "blue" {
  name                = "vnet-blue"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_virtual_network" "green" {
  name                = "vnet-green"
  address_space       = ["10.3.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_virtual_network" "purple" {
  name                = "vnet-purple"
  address_space       = ["10.4.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnets
resource "azurerm_subnet" "red" {
  name                 = "vnet_red_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.red.name
  address_prefixes     = ["10.1.0.0/24"]
}
resource "azurerm_subnet" "blue" {
  name                 = "vnet_blue_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.blue.name
  address_prefixes     = ["10.2.0.0/24"]
}
resource "azurerm_subnet" "green" {
  name                 = "vnet_green_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.green.name
  address_prefixes     = ["10.3.0.0/24"]
}
resource "azurerm_subnet" "purple" {
  name                 = "vnet_purple_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.purple.name
  address_prefixes     = ["10.4.0.0/24"]
}

# VNet peering
resource "azurerm_virtual_network_peering" "red_to_blue" {
  name                      = "red_to_blue"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.red.name
  remote_virtual_network_id = azurerm_virtual_network.blue.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
}
resource "azurerm_virtual_network_peering" "blue_to_red" {
  name                      = "blue_to_red"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.blue.name
  remote_virtual_network_id = azurerm_virtual_network.red.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
}
resource "azurerm_virtual_network_peering" "blue_to_green" {
  name                      = "blue_to_green"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.blue.name
  remote_virtual_network_id = azurerm_virtual_network.green.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
}
resource "azurerm_virtual_network_peering" "green_to_red" {
  name                      = "green_to_red"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.green.name
  remote_virtual_network_id = azurerm_virtual_network.red.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
}

# Network Interface for each VM
resource "azurerm_network_interface" "red" {
  name                = "red"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.red.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip.id
  }
}
resource "azurerm_network_interface" "green" {
  name                = "green"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.green.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "blue" {
  name                = "blue"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.blue.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Virtual Machines
resource "azurerm_linux_virtual_machine" "red" {
  name                = "red"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_A1_v2"

  admin_username      = "admin_user"
  admin_password      = "^4)ZJ>W:pX\"-h8zg&,$^%[3$;^,hO\\rZ" # ^4)ZJ>W:pX"-h8zg&,$^%[3$;^,hO\rZ
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.red.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

}
resource "azurerm_linux_virtual_machine" "green" {
  name                = "green"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_A1_v2"

  admin_username      = "admin_user"
  admin_password      = "^4)ZJ>W:pX\"-h8zg&,$^%[3$;^,hO\\rZ"
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.green.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
resource "azurerm_linux_virtual_machine" "blue" {
  name                = "blue"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_A1_v2"

  admin_username      = "admin_user"
  admin_password      = "^4)ZJ>W:pX\"-h8zg&,$^%[3$;^,hO\\rZ"
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.blue.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

# SSH config. We use SSH to demonstrate evidence of connectivity.
resource "azurerm_public_ip" "ip" {
  name                = "public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "allow-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.rg.name
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.MY_PUBLIC_IP
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
}
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.red.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}