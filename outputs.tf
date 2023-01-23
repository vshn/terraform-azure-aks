output "vnet" {
  value = azurerm_virtual_network.vnet
}

output "clusternet" {
  value = azurerm_subnet.subnet
}

output "kubeconfig" {
  value = module.cluster.kube_config_raw
}
