

#
# Private endpoint
#

module private_endpoint {
  source   = "../../networking/private_endpoint"
  for_each = var.private_endpoints

  resource_id         = azurerm_mssql_server.mssql.id
  name                = each.value.name
  location            = var.resource_groups[each.value.resource_group_key].location
  resource_group_name = var.resource_groups[each.value.resource_group_key].name
  subnet_id           = try(var.vnets[var.client_config.landingzone_key][each.value.vnet_key].subnets[each.value.subnet_key].id, var.vnets[each.value.lz_key][each.value.vnet_key].subnets[each.value.subnet_key].id)
  settings            = each.value
  global_settings     = var.global_settings
  base_tags           = local.tags
  private_dns         = var.private_dns
  client_config       = var.client_config
}
