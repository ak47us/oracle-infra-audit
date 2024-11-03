# This file creates the Azure Kubernetes clusters

provider "azurerm" {
  features {}
  subscription_id = insert_subscription_ID_here_get_it_from_the_az_command
}

resource "azurerm_resource_group" "rg" {
  name     = "aks-resource-group"
  location = "East US"
}

# Clusters:
resource "azurerm_kubernetes_cluster" "aks_cluster_1" {
  name                = "aks-cluster-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2ps_v2"
    vnet_subnet_id = azurerm_subnet.vnet_red_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      default_node_pool
    ]
  }
}

resource "azurerm_kubernetes_cluster" "aks_cluster_2" {
  name                = "aks-cluster-2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks2"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2ps_v2"
    vnet_subnet_id = azurerm_subnet.vnet_blue_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      default_node_pool
    ]
  }

  network_profile {
    network_plugin = "azure"
  }
}

resource "azurerm_kubernetes_cluster" "aks_cluster_3" {
  name                = "aks-cluster-3"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks3"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2ps_v2"
    vnet_subnet_id = azurerm_subnet.vnet_green_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      default_node_pool
    ]
  }

  network_profile {
    network_plugin = "azure"
  }
}

# Networking:
resource "azurerm_virtual_network" "vnet_red" {
  name                = "vnet-red"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "vnet_blue" {
  name                = "vnet-blue"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "vnet_green" {
  name                = "vnet-green"
  address_space       = ["10.3.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "vnet_purple" {
  name                = "vnet-purple"
  address_space       = ["10.4.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "vnet_red_subnet" {
  name                 = "vnet_red_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_red.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "vnet_blue_subnet" {
  name                 = "vnet_blue_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_blue.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_subnet" "vnet_green_subnet" {
  name                 = "vnet_green_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_green.name
  address_prefixes     = ["10.3.1.0/24"]
}

resource "azurerm_subnet" "vnet_purple_subnet" {
  name                 = "vnet_purple_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_purple.name
  address_prefixes     = ["10.4.1.0/24"]
}

resource "azurerm_virtual_network_peering" "red_to_blue" {
  name                      = "red_to_blue"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet_red.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_blue.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
}

resource "azurerm_virtual_network_peering" "blue_to_red" {
  name                      = "blue_to_red"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet_blue.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_red.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
}

# Use this route to test if green subnet members can access the other networks.
# resource "azurerm_virtual_network_peering" "green_to_red" {
#   name                      = "green_to_red"
#   resource_group_name       = azurerm_resource_group.rg.name
#   virtual_network_name      = azurerm_virtual_network.vnet_green.name
#   remote_virtual_network_id = azurerm_virtual_network.vnet_red.id
#   allow_forwarded_traffic   = true
#   allow_gateway_transit     = false
#   use_remote_gateways       = false
# }