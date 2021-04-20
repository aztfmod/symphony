
output "id" {
  # depends_on = [azurerm_resource_group_template_deployment.asr]
  description = "Output the object ID"
  value       = azurerm_recovery_services_vault.asr.id
}

output "name" {
  depends_on  = [azurerm_recovery_services_vault.asr]
  description = "Output the object name"
  value       = azurecaf_name.asr_rg_vault.result
}

output "backup_policies" {
  description = "Output the set of backup policies in this vault"
  value = {
    virtual_machines = azurerm_backup_policy_vm.vm
    file_shares      = azurerm_backup_policy_file_share.fs
  }
}

output "replication_policies" {
  description = "Ouput the set of replication policies in the vault"
  value       = azurerm_site_recovery_replication_policy.policy
}

output "resource_group_name" {
  description = "Output the resource group name"
  value       = var.resource_group_name
}

output soft_delete_enabled {
  description = "Boolean indicating if soft deleted is enabled on the vault."
  value       = try(var.settings.soft_delete_enabled, true)
}

# output rbac_id {
#   depends_on  = [azurerm_resource_group_template_deployment.asr]
#   value       = jsondecode(azurerm_resource_group_template_deployment.asr.output_content).principalId.value
# }
