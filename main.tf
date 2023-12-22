terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.85.0"
    }
  }
}

resource "azurerm_resource_group" "default" {
  name     = "rg-${var.workload}"
  location = var.location
}

module "vnet" {
  source              = "./modules/vnet"
  workload            = var.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
}

resource "azurerm_log_analytics_workspace" "default" {
  name                = "log-${var.workload}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "vm_windows" {
  source              = "./modules/vm/windows"
  workload            = var.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  subnet_id           = module.vnet.subnet_id
  size                = var.vm_windows_size
}

# module "logicapp" {
#   source              = "./modules/logicapp"
#   workload            = var.workload
#   resource_group_name = azurerm_resource_group.default.name
#   location            = azurerm_resource_group.default.location
# }

module "sentinel" {
  source       = "./modules/sentinel"
  workspace_id = azurerm_log_analytics_workspace.default.id

  threat_intelligence_indicator_pattern           = var.threat_intelligence_indicator_pattern
  threat_intelligence_indicator_validate_from_utc = var.threat_intelligence_indicator_validate_from_utc
}
