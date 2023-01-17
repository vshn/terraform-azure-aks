resource "azurerm_subnet" "main" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group.name
  address_prefixes     = var.subnet_address_prefixes
  virtual_network_name = azurerm_virtual_network.vnet.name
}
