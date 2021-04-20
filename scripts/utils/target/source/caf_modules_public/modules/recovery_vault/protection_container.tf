resource "azurerm_site_recovery_protection_container" "protection_container" {
  depends_on = [azurerm_recovery_services_vault.asr, azurerm_site_recovery_fabric.recovery_fabric]
  # depends_on = [time_sleep.delay_create]
  for_each = try(var.settings.protection_containers, {})

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  recovery_vault_name  = azurecaf_name.asr_rg_vault.result
  recovery_fabric_name = azurerm_site_recovery_fabric.recovery_fabric[each.value.recovery_fabric_key].name
}

resource "azurerm_site_recovery_protection_container_mapping" "container-mapping" {
  depends_on = [azurerm_recovery_services_vault.asr, azurerm_site_recovery_fabric.recovery_fabric]
  for_each   = try(var.settings.protection_container_mapping, {})

  name                                      = each.value.name
  resource_group_name                       = var.resource_group_name
  recovery_vault_name                       = azurecaf_name.asr_rg_vault.result
  recovery_fabric_name                      = azurerm_site_recovery_fabric.recovery_fabric[each.value.fabric_key].name
  recovery_source_protection_container_name = azurerm_site_recovery_protection_container.protection_container[each.value.source_protection_container_key].name
  recovery_target_protection_container_id   = azurerm_site_recovery_protection_container.protection_container[each.value.target_protection_container_key].id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.policy[each.value.policy_key].id
}