output "vnet_id" {
  value = azurerm_virtual_network.default.id
}

output "subnet_id" {
  value = azurerm_subnet.default.id
}

output "app_gateway_subnet_id" {
  value = azurerm_subnet.app_gateway.id
}

output "vnet_name" {
  value = azurerm_virtual_network.default.name
}
