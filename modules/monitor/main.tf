locals {
  log_analytics_destination = "log-analytics-destination"
}

### Log Collection Rules ###
resource "azurerm_monitor_data_collection_endpoint" "endpoint1" {
  name                          = "dce-${var.workload}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  kind                          = "Windows"
  public_network_access_enabled = true
  description                   = "Terraform Sentinel Windows VM"
}

# TODO: Operations Solution

# TODO: Reimplement this, not matching with terraform output
resource "azurerm_monitor_data_collection_rule" "rule_1" {
  name                = "dcr-${var.workload}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "Windows"

  # Endpoint
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.endpoint1.id

  destinations {
    log_analytics {
      workspace_resource_id = var.log_analytics_workspace_id
      name                  = local.log_analytics_destination
    }
  }

  # data_flow {
  #   streams      = ["Microsoft-Syslog"]
  #   destinations = [local.log_analytics_destination]
  # }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics", "Microsoft-Perf"]
    destinations = [local.log_analytics_destination]
  }

  data_flow {
    destinations = [
      "la-255964282",
    ]
    output_stream = "Microsoft-Event"
    streams = [
      "Microsoft-Event",
    ]
    transform_kql = "source"
  }

  data_sources {
    windows_event_log {
      name = "eventLogsDataSource"
      streams = [
        "Microsoft-Event",
      ]
      x_path_queries = [
        "Application!*[System[(Level=1 or Level=2)]]",
        "Security!*[System[(band(Keywords,13510798882111488))]]",
        "System!*[System[(Level=1 or Level=2)]]",
      ]
    }

    performance_counter {
      streams                       = ["Microsoft-Perf", "Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers            = ["Processor(*)\\% Processor Time"]
      name                          = "perfcounter-datasource"
    }
  }
}

# Associate to a Data Collection Rule
resource "azurerm_monitor_data_collection_rule_association" "association_1" {
  name                    = "association1"
  target_resource_id      = var.vm_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.rule_1.id
  description             = "Exploring data collection on Azure"
}
