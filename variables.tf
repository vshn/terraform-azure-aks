variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
}

variable "resource_group" {
  description = "Resource group this virtual network and subnet should belong to"
  type = object({
    name     = string
    location = string
  })
}

variable "virtual_network_address_space" {
  description = "The address space of the virtual network"
  type        = list(string)
}

variable "subnet_address_prefixes" {
  description = "The address prefix of the subnet"
  type        = list(string)
}

variable "cluster_name" {
  type        = string
  description = "The name of the AKS cluster"
}

variable "log_analytics_workspace_enabled" {
  type        = bool
  description = "Whether or not to enable Log Analytics Workspace for the AKS cluster"
  default     = false
}

variable "log_analytics_workspace" {
  type = object({
    name = string
    id   = string
  })
  description = "The name of the Log Analytics Workspace to use for the AKS cluster"
  default     = { name = "", id = "" }
}

variable "role_based_access_control_enabled" {
  type        = bool
  description = "THIS VARIABLE SHOULD ALWAYS BE TRUE. IT IS ONLY HERE FOR BACKWARDS COMPATIBILITY."
  default     = true
}

variable "rbac_aad" {
  type        = bool
  description = "Is Azure Active Directory ingration enabled?"
  default     = false
}

variable "rbac_aad_admin_group_object_ids" {
  type        = list(string)
  description = "Object ID of groups with admin access"
  default     = []
}

variable "rbac_aad_managed" {
  type        = bool
  description = "Whether to use managed AAD integration."
  default     = true
}

variable "oidc_issuer_enabled" {
  type        = bool
  description = "Enable or Disable the OIDC issuer URL. Defaults to false."
  default     = false
}

variable "enable_auto_scaling" {
  type        = bool
  description = "Whether or not to enable auto-scaling for the AKS cluster's node pool"
  default     = true
}

variable "node_pool_max_count" {
  type        = number
  description = "The maximum number of nodes to allow in the AKS cluster's node pool"
  default     = 20
}

variable "node_pool_min_count" {
  type        = number
  description = "The minimum number of nodes to maintain in the AKS cluster's node pool"
  default     = 0
}

variable "node_pool_max_pods" {
  type        = number
  description = "The maximum number of pods to allow per node in the AKS cluster's node pool"
  default     = 110
}

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones to use for the AKS cluster's node pool"
  default     = []
}

variable "node_pool_name" {
  type        = string
  description = "The name of the AKS cluster's node pool"
  default     = "workers"
}

variable "os_disk_size_gb" {
  type        = number
  description = "The size of the OS disk for each node in the AKS cluster's node pool, in GB"
  default     = 128
}

variable "node_pool_instance_type" {
  type        = string
  description = "The instance type for each node in the AKS cluster's node pool"
}

variable "aks_network_profile" {
  type = object({
    network_plugin     = string
    network_policy     = string
    dns_service_ip     = string
    docker_bridge_cidr = string
    service_cidr       = string
  })
  description = "Configurations of AKS network profile"
}

variable "kubernetes_version" {
  type        = string
  description = "The version of Kubernetes to use for the AKS cluster"
}

variable "orchestrator_version" {
  type        = string
  description = "The version of the orchestrator to use for the AKS cluster"
  default     = null
}

variable "public_access_cidrs" {
  type        = list(string)
  description = "List of CIDRs to be authorized to access the AKS cluster's API server"
  default     = ["0.0.0.0/0"]
}

variable "appgw_enabled" {
  type        = bool
  description = "Whether or not to enable an Application Gateway for ingress to the AKS cluster"
  default     = false
}

variable "appgw_name" {
  type        = string
  description = "The name of the Application Gateway for ingress to the AKS cluster"
  default     = ""
}

variable "appgw_subnet_cidr" {
  type        = string
  description = "The CIDR of the subnet to use for the Application Gateway for ingress to the AKS cluster"
  default     = ""
}

variable "ARM_CLIENT_ID" {
  type        = string
  description = "The client ID to use when authenticating to Azure"
  default     = ""
}

variable "ARM_CLIENT_SECRET" {
  type        = string
  description = "The client secret to use when authenticating to Azure"
  default     = ""
}

variable "automatic_channel_upgrade" {
  type        = string
  description = "The upgrade channel for this Kubernetes Cluster. Possible values are `patch`, `rapid`, `node-image` and `stable`. By default automatic-upgrades are turned off. Note that you cannot use the `patch` upgrade channel and still specify the patch version using `kubernetes_version`. See [the documentation](https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster) for more information"
  default     = null
}

variable "maintenance_window" {
  type = map(object({
    name = string
    time_in_week = optional(list(object({
      day        = optional(string)
      hour_slots = optional(list(number))
    })))
    not_allowed_time = optional(list(object({
      end   = optional(string)
      start = optional(string)
    })))
  }))
  default = {
    default = {
      name = "default"
      time_in_week = [
        {
          day        = "Tuesday"
          hour_slots = [22, 23]
        }
      ]
      not_allowed_time = []
    }
  }
}

variable "additional_node_pools" {
  type = map(object({
    worker_min_count     = number
    worker_max_count     = number
    worker_max_pods      = number
    worker_instance_type = string
    auto_scaling_enabled = bool
  }))
  default = {}
}

variable "upgrade_settings" {
  description = "Override settings for upgrades"
  type = object({
    override_settings = optional(object({
      force_upgrade = optional(bool)
      until         = optional(string)
    }))
  })
  default = null
}

variable "workload_identity_enabled" {
  description = "Enable or Disable Workload Identity"
  type        = bool
  default     = false
}

variable "ingress_profile" {
  description = "Ingress profile for the AKS cluster"
  type = object({
    web_app_routing = optional(object({
      enabled               = optional(bool)
      dns_zone_resource_ids = optional(list(string))
    }))
  })
  default = null
}

variable "dns_prefix" {
  description = "The DNS prefix of the Managed Cluster"
  type        = string
}
