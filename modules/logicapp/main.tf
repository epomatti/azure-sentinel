resource "azurerm_logic_app_workflow" "default" {
  name                = "logic-${var.workload}"
  location            = var.location
  resource_group_name = var.resource_group_name
}


data "azurerm_managed_api" "azuresentinel" {
  name     = "azuresentinel"
  location = var.location
}

resource "azurerm_api_connection" "logic_app" {
  name                = "azuresentinel-logicapp-${var.workload}"
  resource_group_name = var.resource_group_name
  managed_api_id      = data.azurerm_managed_api.azuresentinel.id
  display_name        = "azuresentinel-logicapp-${var.workload}"

  # parameter_values = {
  #   connectionString = azurerm_servicebus_namespace.example.default_primary_connection_string
  # }

  # tags = {
  #   Hello = "World"
  # }

  # lifecycle {
  #   # NOTE: since the connectionString is a secure value it's not returned from the API
  #   ignore_changes = ["parameter_values"]
  # }
}
