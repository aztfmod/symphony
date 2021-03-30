resource "azurecaf_name" "evh_rule" {
  name          = var.settings.rule_name
  resource_type = "azurerm_eventhub_authorization_rule"
  prefixes      = var.global_settings.prefix
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_eventhub_authorization_rule" "evhub_rule" {
  name                = azurecaf_name.evh_rule.result
  namespace_name      = var.namespace_name
  eventhub_name       = var.eventhub_name
  resource_group_name = var.resource_group_name
  listen              = var.settings.listen
  send                = var.settings.send
  manage              = var.settings.manage
}