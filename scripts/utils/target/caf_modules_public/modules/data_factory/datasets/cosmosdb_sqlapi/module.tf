resource "azurerm_data_factory_dataset_cosmosdb_sqlapi" "dataset" {
  name                  = var.name
  resource_group_name   = var.resource_group_name
  data_factory_name     = var.data_factory_name
  linked_service_name   = var.linked_service_name
  folder                = try(var.folder, null)
  description           = try(var.description, null)
  annotations           = try(var.annotations, null)
  parameters            = try(var.parameters, null)
  additional_properties = try(var.additional_properties, null)
  collection_name       = try(var.collection_name, null)

  dynamic "schema_column" {
    for_each = try(var.schema_column, null) != null ? [var.schema_column] : []

    content {
      name        = schema_column.value.name
      type        = lookup(schema_column.value, "type", null)
      description = lookup(schema_column.value, "description", null)
    }
  }
}