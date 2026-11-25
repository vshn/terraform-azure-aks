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
Enabling the OIDC issuer and workload identity can't be undone.

```hcl
module "cluster" {
  # ...
  alb_subnet_address_prefixes = ["10.0.16.0/24"] # within virtual_network_address_space
}
```

To keep an existing cluster unchanged, set `application_load_balancer_enabled`, `oidc_issuer_enabled` and `workload_identity_enabled` to `false`, or `true` for the latter two if they're already enabled.

### Prerequisites

These are needed once per subscription and cluster before the first apply with `application_load_balancer_enabled`, otherwise the apply fails part way through.

1. Register the preview features and resource providers on the subscription.
   The features aren't listed under "Preview features" in the Azure portal, use the Azure CLI:

   ```bash
   az feature register --namespace Microsoft.ContainerService --name ManagedGatewayAPIPreview
   az feature register --namespace Microsoft.ContainerService --name ApplicationLoadBalancerPreview

   # Repeat until both are "Registered", this can take 15 minutes
   az feature show --namespace Microsoft.ContainerService --name ManagedGatewayAPIPreview --query properties.state -o tsv
   az feature show --namespace Microsoft.ContainerService --name ApplicationLoadBalancerPreview --query properties.state -o tsv

   az provider register --namespace Microsoft.ContainerService # propagates the features
   az provider register --namespace Microsoft.ServiceNetworking
   az provider register --namespace Microsoft.NetworkFunction
   ```

   Missing registrations fail with `MissingSubscriptionRegistration`.

2. Allow the identity running Terraform to create the role assignments for the ALB Controller identity.
   `Contributor` isn't sufficient, the apply then fails with `AuthorizationFailed` on `Microsoft.Authorization/roleAssignments/write`.
   Someone with `Owner` or `User Access Administrator` on the cluster's resource group assigns the identity **Role Based Access Control Administrator** on that resource group, constrained to the roles **AppGw for Containers Configuration Manager** and **Network Contributor**.

   In the Azure portal: resource group → *Access control (IAM)* → *Add role assignment* → *Privileged administrator roles* → *Role Based Access Control Administrator* → select the identity under *Members* → under *Conditions* choose *Allow user to only assign selected roles to selected principals*, *Constrain roles* and select both roles.
   Don't constrain the principals, the ALB Controller identity is only created by the apply.
   Role assignments can take a few minutes to take effect.

### Default Gateway

The [azure-application-gateway-for-containers](https://github.com/projectsyn/component-azure-application-gateway-for-containers) Commodore component deploys a shared `Gateway` on the default frontend. Applications attach their `HTTPRoute`s to it. The resulting `Gateway`:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: default
  namespace: syn-alb
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
