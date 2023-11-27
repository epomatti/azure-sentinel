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
