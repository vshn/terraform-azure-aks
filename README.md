# VSHN Terraform Module Azure AKS

This module does the following:

- Create a virtual network for the AKS cluster
- Create a subnet for the AKS cluster
- Create an AKS cluster

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
