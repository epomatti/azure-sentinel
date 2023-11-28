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

resource "azurerm_sentinel_alert_rule_scheduled" "vm" {
  name                       = "Azure VM Deletion"
  display_name               = "Azure VM Deletion"
  description                = "A simple detection to alert when someone deletes Azure Virtual Machine."
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.default.workspace_id

  tactics  = ["Impact"]
  severity = "Medium"
  enabled  = true

  query = file("${path.module}/query.sql")

  entity_mapping {
    entity_type = "Account"

    field_mapping {
      identifier  = "Name"
      column_name = "Caller"
    }
  }

  entity_mapping {
    entity_type = "IP"

    field_mapping {
      identifier  = "Address"
      column_name = "CallerIpAddress"
    }
  }

  query_frequency = "PT5M"
  query_period    = "PT5H"

  incident_configuration {
    create_incident = true

    grouping {
      enabled                 = true
      reopen_closed_incidents = false
    }
  }

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.default]
}
