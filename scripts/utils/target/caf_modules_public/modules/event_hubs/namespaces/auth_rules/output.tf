output id {
  value = azurerm_eventhub_namespace_authorization_rule.evh_ns_rule.id
}

output primary_connection_string_alias {
  value = azurerm_eventhub_namespace_authorization_rule.evh_ns_rule.primary_connection_string_alias
}

output secondary_connection_string_alias {
  value = azurerm_eventhub_namespace_authorization_rule.evh_ns_rule.secondary_connection_string_alias
}

output name {
  value       = var.namespace_name
  description = "Name of the authorization rule"
}

output resource_group_name {
  value       = var.resource_group_name
  description = "Name of the resource group"
}
