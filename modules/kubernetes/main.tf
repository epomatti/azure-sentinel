resource "azurerm_kubernetes_cluster" "default" {
  name                = "aks-sentinel-cluster"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "sentinelaks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }
}
