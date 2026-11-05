locals {
  resource_group_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group.name}"

  # The ALB Controller add-on requires the managed Gateway API add-on.
  # Leaving `application_load_balancer` null when disabled keeps the cluster on the GA API version.
  ingress_profile = var.ingress_profile == null && !var.application_load_balancer_enabled ? null : {
    web_app_routing           = try(var.ingress_profile.web_app_routing, null)
    gateway_api               = var.application_load_balancer_enabled ? { installation = "Standard" } : null
    application_load_balancer = var.application_load_balancer_enabled ? { enabled = true } : null
  }
}
