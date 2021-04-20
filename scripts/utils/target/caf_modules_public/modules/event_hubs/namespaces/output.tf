output id {
  description = "The EventHub Namespace ID."
  value       = azurerm_eventhub_namespace.evh.id
}

output name {
  description = "The EventHub Namespace name."
  value       = azurerm_eventhub_namespace.evh.name
}

output resource_group_name {
  value       = var.resource_group_name
  description = "Name of the resource group"
}

output location {
  value       = var.location
  description = "Location of the service"
}
