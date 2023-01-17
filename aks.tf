module "cluster" {
  source  = "Azure/aks/azurerm"
  version = "6.2.0"

  cluster_name        = var.cluster_name
  resource_group_name = var.resource_group.name
  prefix              = var.prefix

  log_analytics_workspace_enabled   = var.log_analytics_workspace_enabled
  log_analytics_workspace           = var.log_analytics_workspace
  log_analytics_solution_id         = var.log_analytics_solution_id
  role_based_access_control_enabled = var.role_based_access_control_enabled
  enable_auto_scaling               = var.enable_auto_scaling
  agents_max_count                  = var.node_pool_max_count
  agents_min_count                  = var.node_pool_min_count
  agents_max_pods                   = var.node_pool_max_pods
  agents_pool_name                  = var.node_pool_name
  os_disk_size_gb                   = var.os_disk_size_gb
  agents_size                       = var.node_pool_instance_type

  network_plugin                 = var.aks_network_profile.network_plugin
  network_policy                 = var.aks_network_profile.network_policy
  net_profile_dns_service_ip     = var.aks_network_profile.dns_service_ip
  net_profile_docker_bridge_cidr = var.aks_network_profile.docker_bridge_cidr
  net_profile_service_cidr       = var.aks_network_profile.service_cidr

  vnet_subnet_id = azurerm_subnet.main.id

  kubernetes_version   = var.kubernetes_version
  orchestrator_version = var.orchestrator_version

  api_server_authorized_ip_ranges = var.public_access_cidrs

  ingress_application_gateway_enabled     = var.appgw_enabled
  ingress_application_gateway_name        = var.appgw_name
  ingress_application_gateway_subnet_cidr = var.appgw_subnet_cidr

  client_id     = var.ARM_CLIENT_ID
  client_secret = var.ARM_CLIENT_SECRET
}
