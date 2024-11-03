# This helm file runs on all clusters created in kubernetes.tf

provider "helm" {
  alias      = "aks_cluster_1"
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks_cluster_1.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks_cluster_1.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks_cluster_1.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks_cluster_1.kube_config.0.cluster_ca_certificate)
  }
}

provider "helm" {
  alias      = "aks_cluster_2"
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks_cluster_2.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks_cluster_2.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks_cluster_2.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks_cluster_2.kube_config.0.cluster_ca_certificate)
  }
}

# resource "helm_release" "istio_base_1" {
#   provider   = helm.aks_cluster_1
#   name       = "istio-base"
#   namespace  = "istio-system"
#   chart      = "base"
#   repository = "https://istio-release.storage.googleapis.com/charts"
#
#   values = [
#     file("../helm/istio/values.yaml")
#   ]
# }
#
# resource "helm_release" "istio_base_2" {
#   provider   = helm.aks_cluster_2
#   name       = "istio-base"
#   namespace  = "istio-system"
#   chart      = "base"
#   repository = "https://istio-release.storage.googleapis.com/charts"
#
#   values = [
#     file("../helm/istio/values.yaml")
#   ]
# }
#
# resource "helm_release" "istio_d_1" {
#   provider   = helm.aks_cluster_1
#   name       = "istio-d"
#   namespace  = "istio-system"
#   chart      = "istiod"
#   repository = "https://istio-release.storage.googleapis.com/charts"
#
#   values = [
#     file("../helm/istio/values.yaml")
#   ]
# }
#
# resource "helm_release" "istio_d_2" {
#   provider   = helm.aks_cluster_2
#   name       = "istio-d"
#   namespace  = "istio-system"
#   chart      = "istiod"
#   repository = "https://istio-release.storage.googleapis.com/charts"
#
#   values = [
#     file("../helm/istio/values.yaml")
#   ]
# }

#istio-multi-primary
# resource "helm_release" "istio_d_1" {
#   provider   = helm.aks_cluster_1
#   name       = "istio-d"
#   namespace  = "istio-system"
#   chart      = "istiod"
#   repository = "https://istio-release.storage.googleapis.com/charts"
#
#   values = [
#     file("../helm/istio/values.yaml")
#   ]
# }
#
# resource "helm_release" "istio_d_2" {
#   provider   = helm.aks_cluster_2
#   name       = "istio-d"
#   namespace  = "istio-system"
#   chart      = "istiod"
#   repository = "https://istio-release.storage.googleapis.com/charts"
#
#   values = [
#     file("../helm/istio/values.yaml")
#   ]
# }

# resource "local_file" "kubeconfig_1" {
#   content  = azurerm_kubernetes_cluster.aks_cluster_1.kube_admin_config_raw
#   filename = "${path.module}/aks_kubeconfig_1.yaml"
# }
#
# resource "local_file" "kubeconfig_2" {
#   content  = azurerm_kubernetes_cluster.aks_cluster_2.kube_admin_config_raw
#   filename = "${path.module}/aks_kubeconfig_2.yaml"
# }

# resource "helm_release" "consul_aks1" {
#   provider   = helm.aks_cluster_1
#   name       = "consul"
#   chart      = "consul"
#   namespace  = "default"
#   repository = "https://helm.releases.hashicorp.com"
#
#   values     = [file("../helm/consul/values.yaml")]
#   depends_on = [local_file.kubeconfig_1]
# }
#
# resource "helm_release" "consul_aks2" {
#   provider   = helm.aks_cluster_2
#   name       = "consul"
#   chart      = "consul"
#   namespace  = "istio-system"
#   repository = "https://helm.releases.hashicorp.com"
#
#   values     = [file("../helm/consul/values.yaml")]
#   depends_on = [local_file.kubeconfig_2]
# }

# resource "helm_release" "http-test-server1" {
#   provider   = helm.aks_cluster_1
#   name       = "http-test-server"
#   namespace  = "istio-system"
#   chart      = "../helm/http-test-server/"
#
#   values = [
#     file("../helm/http-test-server/values.yaml")
#   ]
# }
#
# resource "helm_release" "http-test-server2" {
#   provider   = helm.aks_cluster_2
#   name       = "http-test-server"
#   namespace  = "istio-system"
#   chart      = "../helm/http-test-server/"
#
#   values = [
#     file("../helm/http-test-server/values.yaml")
#   ]
# }
