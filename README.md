# VSHN Terraform Module Azure AKS

This module does the following:

- Create a virtual network for the AKS cluster
- Create a subnet for the AKS cluster
- Create an AKS cluster
- Optionally enable the Application Gateway for Containers ALB Controller add-on

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

Setting `application_load_balancer_enabled = true` enables the AKS managed Gateway API and ALB Controller add-ons and creates a subnet delegated to Application Gateway for Containers, which the add-on identity may join.
Application Gateway for Containers resources are then created by the ALB Controller ("managed" deployment) from `ApplicationLoadBalancer` resources in the cluster, in the node resource group.
Deleting an `ApplicationLoadBalancer` deletes its Azure resources, and frontend FQDNs change when recreated.

Requires the `ManagedGatewayAPIPreview` and `ApplicationLoadBalancerPreview` features and the `Microsoft.ServiceNetworking` provider to be registered on the subscription.

```hcl
module "cluster" {
  # ...
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  application_load_balancer_enabled = true
  alb_subnet_address_prefixes       = ["10.0.16.0/24"] # within virtual_network_address_space, 256 addresses per ApplicationLoadBalancer
}
```

Create an `ApplicationLoadBalancer` using the `alb_subnet_id` output, and reference it from a `Gateway`; each `Gateway` gets its own frontend:

```yaml
apiVersion: alb.networking.azure.io/v1
kind: ApplicationLoadBalancer
metadata:
  name: alb
  namespace: alb-infra
spec:
  associations:
    - <alb_subnet_id>
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: gateway
  namespace: alb-infra
  annotations:
    alb.networking.azure.io/alb-namespace: alb-infra
    alb.networking.azure.io/alb-name: alb
spec:
  gatewayClassName: azure-alb-external
  listeners:
    - name: http
      port: 80
      protocol: HTTP
      allowedRoutes:
        namespaces:
          from: All
```
