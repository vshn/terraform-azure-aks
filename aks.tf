data "azurerm_client_config" "current" {}

module "cluster" {
  source  = "Azure/avm-res-containerservice-managedcluster/azurerm"
  version = "0.6.6"

  name                     = var.cluster_name
  parent_id                = local.resource_group_id
  location                 = var.resource_group.location
  enable_rbac              = var.role_based_access_control_enabled
  ingress_profile          = var.ingress_profile
  kubernetes_version       = var.kubernetes_version
  dns_prefix               = var.dns_prefix
  maintenanceconfiguration = var.maintenance_window
  upgrade_settings         = var.upgrade_settings

  aad_profile = {
    admin_group_object_ids = var.rbac_aad_admin_group_object_ids
    tenant_id              = data.azurerm_client_config.current.tenant_id
    managed                = var.rbac_aad_managed
  }

  addon_profile_oms_agent = var.log_analytics_workspace_enabled ? {
    enabled = true
    config = {
      log_analytics_workspace_resource_id = var.log_analytics_workspace.id
    }
  } : null

  default_agent_pool = {
    name                 = var.node_pool_name
    vm_size              = var.node_pool_instance_type
    enable_auto_scaling  = var.enable_auto_scaling
    min_count            = var.node_pool_min_count
    max_count            = var.node_pool_max_count
    max_pods             = var.node_pool_max_pods
    availability_zones   = var.availability_zones
    orchestrator_version = var.orchestrator_version
    os_disk_size_gb      = var.os_disk_size_gb
    vnet_subnet_id       = azurerm_subnet.subnet.id
    upgrade_settings = {
      drain_timeout_in_minutes = 30
    }
  }

  agent_pools = {
    for name, pool in var.additional_node_pools : name => {
      name                 = name
      vm_size              = pool.worker_instance_type
      enable_auto_scaling  = pool.auto_scaling_enabled
      min_count            = pool.worker_min_count
      max_count            = pool.worker_max_count
      max_pods             = pool.worker_max_pods
      vnet_subnet_id       = azurerm_subnet.subnet.id
      availability_zones   = var.availability_zones
      orchestrator_version = var.orchestrator_version
      upgrade_settings = {
        drain_timeout_in_minutes = 30
      }
    }
  }

  api_server_access_profile = {
    authorized_ip_ranges = var.public_access_cidrs
  }

  auto_upgrade_profile = {
    upgrade_channel = var.automatic_channel_upgrade
  }

  managed_identities = {
    system_assigned = true
  }

  network_profile = {
    network_plugin = var.aks_network_profile.network_plugin
    network_policy = var.aks_network_profile.network_policy
    dns_service_ip = var.aks_network_profile.dns_service_ip
    service_cidr   = var.aks_network_profile.service_cidr
  }

  oidc_issuer_profile = {
    enabled = var.oidc_issuer_enabled
  }

  security_profile = {
    workload_identity = {
      enabled = var.workload_identity_enabled
    }
  }
}
