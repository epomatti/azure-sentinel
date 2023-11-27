resource "azurerm_sentinel_log_analytics_workspace_onboarding" "default" {
  workspace_id = var.workspace_id
}

resource "azurerm_sentinel_threat_intelligence_indicator" "custom" {
  workspace_id      = var.workspace_id
  pattern_type      = "domain-name"
  pattern           = var.threat_intelligence_indicator_pattern
  source            = "Microsoft Sentinel"
  validate_from_utc = var.threat_intelligence_indicator_validate_from_utc
  display_name      = var.threat_intelligence_indicator_pattern

  threat_types = ["malicious-activity"]

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.default]
}

# ### Data Connectors ###
# resource "azurerm_sentinel_data_connector_office_365" "microsoft365" {
#   name                       = "microsoft365"
#   log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.default.workspace_id

#   exchange_enabled   = true
#   sharepoint_enabled = true
#   teams_enabled      = true

#   depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.default]
# }

# resource "azurerm_sentinel_data_connector_azure_active_directory" "entraid" {
#   name                       = "entraid"
#   log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.default.workspace_id

#   depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.default]
# }
