output "vnet" {
  value = azurerm_virtual_network.vnet
}

output "clusternet" {
  value = azurerm_subnet.subnet
}

output "kubeconfig" {
  value = module.cluster.kube_config_raw
}

output "kubelet_identity" {
  description = "The kubelet managed identity of the AKS cluster."
  value       = module.cluster.kubelet_identity
}
