module "cluster" {
  source  = "Azure/aks/azurerm//v4"
  version = "9.4.1"

  cluster_name        = var.cluster_name
  resource_group_name = var.resource_group.name
  prefix              = var.prefix

  log_analytics_workspace_enabled      = var.log_analytics_workspace_enabled
  log_analytics_workspace              = var.log_analytics_workspace
  log_analytics_solution               = var.log_analytics_solution
  role_based_access_control_enabled    = var.role_based_access_control_enabled
  rbac_aad                             = var.rbac_aad
  rbac_aad_managed                     = var.rbac_aad_managed
  rbac_aad_admin_group_object_ids      = var.rbac_aad_admin_group_object_ids
  oidc_issuer_enabled                  = var.oidc_issuer_enabled
  enable_auto_scaling                  = var.enable_auto_scaling
  agents_max_count                     = var.node_pool_max_count
  agents_min_count                     = var.node_pool_min_count
  agents_max_pods                      = var.node_pool_max_pods
  agents_pool_name                     = var.node_pool_name
  agents_availability_zones            = var.availability_zones
  os_disk_size_gb                      = var.os_disk_size_gb
  agents_size                          = var.node_pool_instance_type
  agents_pool_drain_timeout_in_minutes = 30

  network_plugin             = var.aks_network_profile.network_plugin
  network_policy             = var.aks_network_profile.network_policy
  net_profile_dns_service_ip = var.aks_network_profile.dns_service_ip
  net_profile_service_cidr   = var.aks_network_profile.service_cidr

  vnet_subnet_id = azurerm_subnet.subnet.id

  kubernetes_version   = var.kubernetes_version
  orchestrator_version = var.orchestrator_version

  api_server_authorized_ip_ranges = var.public_access_cidrs

  client_id     = var.ARM_CLIENT_ID
  client_secret = var.ARM_CLIENT_SECRET

  automatic_channel_upgrade = var.automatic_channel_upgrade
  maintenance_window        = var.maintenance_window

  lifecycle {
    ignore_changes = [
      upgrade_override
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "worker" {
  for_each              = var.additional_node_pools
  name                  = each.key
  kubernetes_cluster_id = module.cluster.aks_id

  vm_size = each.value.worker_instance_type

  orchestrator_version = var.orchestrator_version

  auto_scaling_enabled = each.value.auto_scaling_enabled
  min_count            = each.value.worker_min_count
  max_count            = each.value.worker_max_count
  max_pods             = each.value.worker_max_pods

  vnet_subnet_id = azurerm_subnet.subnet.id
  zones          = var.availability_zones
}
