output "vnet" {
  value = azurerm_virtual_network.vnet
}

output "clusternet" {
  value = azurerm_subnet.subnet
}

output "k8s_host" {
  value = module.cluster.host
}

output "k8s_username" {
  value = module.cluster.username
}

output "k8s_password" {
  value = module.cluster.password
}
