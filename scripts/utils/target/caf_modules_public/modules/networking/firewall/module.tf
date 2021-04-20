#Reference: https://www.terraform.io/docs/providers/azurerm/r/firewall.html

resource "azurecaf_name" "fw" {
  name          = var.name
  resource_type = "azurerm_firewall"
  prefixes      = var.global_settings.prefix
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_firewall" "fw" {

  name                = azurecaf_name.fw.result
  resource_group_name = var.resource_group_name
  location            = var.location
  threat_intel_mode   = try(var.settings.threat_intel_mode, "Alert")
  zones               = try(var.settings.zones, null)
  tags                = local.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = (var.public_ip_id != null) ? var.public_ip_id : var.public_ip_addresses[var.public_ip_keys[0]].id
  }

  dynamic "ip_configuration" {
    for_each = {
      for key, value in try(var.public_ip_addresses, {}) : key => value
      if(var.public_ip_id == null) && try(contains(var.public_ip_keys, key) && (key != var.public_ip_keys[0]), false)
    }
    content {
      name                 = ip_configuration.key
      public_ip_address_id = ip_configuration.value.id
    }
  }
}
