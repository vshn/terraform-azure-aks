output "vnet" {
  value = azurerm_virtual_network.vnet
}

output "clusternet" {
  value = azurerm_subnet.subnet
}

output "kubeconfig" {
  value = module.cluster.kube_config
}

output "kubelet_identity" {
  description = "The kubelet managed identity of the AKS cluster."
  value       = module.cluster.kubelet_identity
}

output "alb_controller_identity" {
  description = "The managed identity (`clientId`, `objectId`, `resourceId`) of the ALB Controller add-on. Null when `application_load_balancer_enabled` is false."
  value       = var.application_load_balancer_enabled ? module.cluster.ingress_profile_application_load_balancer_identity : null
}

output "alb_subnet_id" {
  description = "ID of the subnet delegated to Application Gateway for Containers, for the `associations` of an `ApplicationLoadBalancer`. Null when `application_load_balancer_enabled` is false."
  value       = var.application_load_balancer_enabled ? azurerm_subnet.alb[0].id : null
}

output "default_alb" {
  description = "The default Application Gateway for Containers: `id` for the `alb.networking.azure.io/alb-id` Gateway annotation, `frontend` for the `alb.networking.azure.io/alb-frontend` Gateway address and `fqdn` of that frontend. Null when `application_load_balancer_enabled` is false."
  value = var.application_load_balancer_enabled ? {
    id       = azurerm_application_load_balancer.default[0].id
    frontend = azurerm_application_load_balancer_frontend.default[0].name
    fqdn     = azurerm_application_load_balancer_frontend.default[0].fully_qualified_domain_name
  } : null
}
