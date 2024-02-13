terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.91.0"
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
  count               = var.create_vm_windows ? 1 : 0
  source              = "./modules/vm/windows"
  workload            = var.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  subnet_id           = module.vnet.subnet_id
  size                = var.vm_windows_size
}

module "waf" {
  count               = var.create_waf ? 1 : 0
  source              = "./modules/waf"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
}

module "app_gateway" {
  count               = var.create_waf ? 1 : 0
  source              = "./modules/agw"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  subnet_id           = module.vnet.app_gateway_subnet_id
  firewall_policy_id  = module.waf[0].policy_id
  vnet_name           = module.vnet.vnet_name
}

module "sentinel" {
  source       = "./modules/sentinel"
  workspace_id = azurerm_log_analytics_workspace.default.id

  threat_intelligence_indicator_pattern           = var.threat_intelligence_indicator_pattern
  threat_intelligence_indicator_validate_from_utc = var.threat_intelligence_indicator_validate_from_utc
}

### Monitor (Data collection rules) ###
# module "monitor" {
#   source              = "./modules/monitor"
#   resource_group_name = azurerm_resource_group.default.name
#   location            = azurerm_resource_group.default.location
#   workload            = var.workload

#   log_analytics_workspace_id = azurerm_log_analytics_workspace.default.id
#   vm_id                      = module.vm_windows.vm_id
# }

# module "logicapp" {
#   source              = "./modules/logicapp"
#   workload            = var.workload
#   resource_group_name = azurerm_resource_group.default.name
#   location            = azurerm_resource_group.default.location
# }
