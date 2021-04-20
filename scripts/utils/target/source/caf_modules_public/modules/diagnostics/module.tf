resource "azurerm_monitor_diagnostic_setting" "diagnostics" {

  for_each = {
    for key, profile in var.profiles : key => profile
    if var.diagnostics.diagnostics_definition != {} # Disable diagnostics when not enabled in the launchpad
  }

  name               = try(format("%s%s", try(var.global_settings.prefix_with_hyphen, ""), each.value.name), format("%s%s", try(var.global_settings.prefix_with_hyphen, ""), var.diagnostics.diagnostics_definition[each.value.definition_key].name))
  target_resource_id = var.resource_id

  eventhub_name                  = each.value.destination_type == "event_hub" ? try(var.diagnostics.event_hub_namespaces[var.diagnostics.diagnostics_destinations.event_hub_namespaces[each.value.destination_key].event_hub_namespace_key].name, null) : null
  eventhub_authorization_rule_id = each.value.destination_type == "event_hub" ? format("%s/authorizationrules/RootManageSharedAccessKey", var.diagnostics.event_hub_namespaces[var.diagnostics.diagnostics_destinations.event_hub_namespaces[each.value.destination_key].event_hub_namespace_key].id) : null

  log_analytics_workspace_id     = each.value.destination_type == "log_analytics" ? var.diagnostics.log_analytics[var.diagnostics.diagnostics_destinations.log_analytics[each.value.destination_key].log_analytics_key].id : null
  log_analytics_destination_type = each.value.destination_type == "log_analytics" ? lookup(var.diagnostics.diagnostics_definition[each.value.definition_key], "log_analytics_destination_type", null) : null

  storage_account_id = each.value.destination_type == "storage" ? var.diagnostics.storage_accounts[var.diagnostics.diagnostics_destinations.storage[each.value.destination_key][var.resource_location].storage_account_key].id : null

  dynamic "log" {
    for_each = lookup(var.diagnostics.diagnostics_definition[each.value.definition_key].categories, "log", {})
    content {
      category = log.value[0]
      enabled  = log.value[1]

      dynamic "retention_policy" {
        for_each = length(log.value) > 2 ? [1] : []
        content {
          enabled = log.value[2]
          days    = log.value[3]
        }
      }
    }
  }

  dynamic "metric" {
    for_each = lookup(var.diagnostics.diagnostics_definition[each.value.definition_key].categories, "metric", {})
    content {
      category = metric.value[0]
      enabled  = metric.value[1]

      dynamic "retention_policy" {
        for_each = length(metric.value) > 2 ? [1] : []
        content {
          enabled = metric.value[2]
          days    = metric.value[3]
        }
      }
    }
  }
}