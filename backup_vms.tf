resource "azurerm_backup_protected_vm" "backup_protected_vm" {
  for_each            = { for vm in var.backup_vms : vm.vm_name => vm }
  resource_group_name = each.value.rsv_rg
  recovery_vault_name = each.value.rsv_name
  source_vm_id        = data.azurerm_virtual_machine.vm[each.key].id
  backup_policy_id    = data.azurerm_backup_policy_vm.backup_policy[each.key].id
}