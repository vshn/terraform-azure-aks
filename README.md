# VSHN Terraform Module Azure AKS

This module does the following:

- Create a virtual network for the AKS cluster
- Create a subnet for the AKS cluster
- Create an AKS cluster
- Set up Application Gateway for Containers (ALB Controller add-on and a default Application Gateway for Containers)

## Example usage

```hcl
# create a resource group
resource "azurerm_resource_group" "rg_cluster" {
  name     = "my-cluster"
  location = "Switzerland North"
}

module "cluster" {
  source = "git::ssh://git@git.vshn.net/vshn-terraform/module-azure-aks.git?ref=v1.10.0"

  # fill out the variables
  # ...

  # this is important, otherwise initial plan / apply fails
  depends_on = [
    azurerm_resource_group.rg_cluster
  ]
}
```

## Application Gateway for Containers

`application_load_balancer_enabled` (default `true`) enables the AKS managed Gateway API and ALB Controller add-ons and creates:

- a subnet delegated to Application Gateway for Containers (`alb_subnet_address_prefixes`, required)
- a default Application Gateway for Containers `<cluster_name>-alb` with one frontend `default`, managed by Terraform so its FQDN is stable
- role assignments for the add-on identity on the default Application Gateway for Containers and the subnet

It requires `oidc_issuer_enabled`, `workload_identity_enabled` (both default `true`) and the `azure` network plugin.
The `ManagedGatewayAPIPreview` and `ApplicationLoadBalancerPreview` features and the `Microsoft.ServiceNetworking` provider must be registered on the subscription.

```hcl
module "cluster" {
  # ...
  alb_subnet_address_prefixes = ["10.0.16.0/24"] # within virtual_network_address_space
}
```

### Default Gateway

Create a shared `Gateway` on the default frontend using the `default_alb` output; applications attach their `HTTPRoute`s to it:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: default
  namespace: alb-system
  annotations:
    alb.networking.azure.io/alb-id: <default_alb.id>
spec:
  gatewayClassName: azure-alb-external
  addresses:
    - type: alb.networking.azure.io/alb-frontend
      value: default # default_alb.frontend
  listeners:
    - name: http
      port: 80
      protocol: HTTP
      allowedRoutes:
        namespaces:
          from: All
```

### Additional Application Gateways for Containers

Further Application Gateways for Containers can be created by the ALB Controller ("managed" deployment) from `ApplicationLoadBalancer` resources using the delegated subnet (`alb_subnet_id` output). Each needs 256 addresses in the subnet.
Deleting an `ApplicationLoadBalancer` deletes its Azure resources, and frontend FQDNs change when recreated.

```yaml
apiVersion: alb.networking.azure.io/v1
kind: ApplicationLoadBalancer
metadata:
  name: alb
  namespace: my-team
spec:
  associations:
    - <alb_subnet_id>
```

Gateways reference it with the `alb.networking.azure.io/alb-namespace` and `alb.networking.azure.io/alb-name` annotations instead of `alb-id`; each such `Gateway` gets its own frontend.
