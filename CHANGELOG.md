# Changelog

## v2.6.0
- Set default value for drain timeout for default node pool

## v2.5.1
- Update terraform azure/aks/azurerm to v9.1.0 

## v2.5.0
- Update terraform azure/aks/azurerm to v9 

## v2.4.0

- Update terraform azure/aks/azurerm to v8
- Remove support for ingress_application_gateway

## v2.3.0

- Allow configuration of `role_based_access_control_enabled`
**WARNING:** THIS VARIABLE SHOULD ALWAYS BE SET TO `true`!
THIS IS ONLY PROVIDED FOR BACKWARDS COMPATIBILITY!

## v2.2.0

- Set default value for `public_access_cidrs` to `["0.0.0.0/0"]`

## v2.1.0

- Update Terraform Azure/aks/azurerm to v7.1.0

## v2.0.0

**WARNING:** This release permanently enables Kubernetes RBAC.
Clusters created without RBAC enabled **WILL BE RECREATED**!

- Permanently enable Kubernetes RBAC

## v1.10.0

- Update Terraform Azure/aks/azurerm to v6.7.0

## v1.9.0

- Add support for enabling the OIDC Issuer on a Cluster

## v1.8.1

- Add support for adding AzureAD RBAC Admin Group IDs

## v1.8.0

- Add support for AzureAD RBAC
- Update Terraform Azure/aks/azurerm to v6.6.0

## v1.7.0

- Add support for multiple nodepools

## v1.6.3

- Make `ARM_CLIENT_ID` and `ARM_CLIENT_SECRET` optional

## v1.6.2

- Disable automatic AKS upgrades by default

## v1.6.1

- Default orchestrator_version to null

## v1.6.0

- Enable automatic AKS upgrades
- Configure maintenance window (Tuesday 22, 23pm)

## v1.5.0

- Update Terraform Azure/aks/azurerm to v6.5.0

## v1.4.0

- Default node_pool_max_pods to 110

## v1.3.0

- Fix Terraform output for Kubernetes access credentials

## v1.2.2

- Fix log_analytics_workspace default and type

## v1.2.1

- Fix Terraform output for Kubernetes access credentials
- Fix variable defaults

## v1.2.0

- Add `availability_zones` variable
- Set defaults

## v1.1.1

- Fix subnet reference in AKS resource

## v1.1.0

- Define outputs for the module

## v1.0.0

- Initial release
