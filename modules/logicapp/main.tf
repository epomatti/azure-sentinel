resource "azurerm_logic_app_workflow" "default" {
  name                = "logic-${var.workload}"
  location            = var.location
  resource_group_name = var.resource_group_name
}
