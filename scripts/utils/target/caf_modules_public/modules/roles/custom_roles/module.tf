
resource "azurecaf_name" "custom_role" {
  name          = var.custom_role.name
  resource_type = "azurerm_resource_group"
  #TODO: need to be changed to appropriate resource (no caf reference for now)
  prefixes      = var.global_settings.prefix
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_role_definition" "custom_role" {
  name = azurecaf_name.custom_role.result

  # TODO: refactor scope to include other scopes like RG, resources.
  scope       = lookup(var.custom_role, "scope", var.subscription_primary)
  description = var.custom_role.description

  permissions {
    actions          = lookup(var.custom_role.permissions, "actions", [])
    not_actions      = lookup(var.custom_role.permissions, "not_actions", [])
    data_actions     = lookup(var.custom_role.permissions, "data_actions", [])
    not_data_actions = lookup(var.custom_role.permissions, "not_data_actions", [])
  }

  assignable_scopes = [lookup(var.custom_role, "scope", var.subscription_primary)]

}