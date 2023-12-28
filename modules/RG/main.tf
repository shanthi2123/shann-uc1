resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}
resource "azurerm_network_ddos_protection_plan" "example" {
    name = var.network_ddos_protection_plan_name
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}