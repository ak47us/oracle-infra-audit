# This file creates the istio-system namespace in each cluster.

provider "kubernetes" {
  alias = "aks_cluster_1"
  host                   = azurerm_kubernetes_cluster.aks_cluster_1.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks_cluster_1.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks_cluster_1.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks_cluster_1.kube_config.0.cluster_ca_certificate)
}

provider "kubernetes" {
  alias = "aks_cluster_2"
  host                   = azurerm_kubernetes_cluster.aks_cluster_2.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks_cluster_2.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks_cluster_2.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks_cluster_2.kube_config.0.cluster_ca_certificate)
}

# resource "kubernetes_namespace" "istio-system1" {
#   provider = kubernetes.aks_cluster_1
#   metadata {
#     name = "istio-system"
#   }
# }
#
# resource "kubernetes_namespace" "istio-system2" {
#   provider = kubernetes.aks_cluster_2
#   metadata {
#     name = "istio-system"
#   }
# }