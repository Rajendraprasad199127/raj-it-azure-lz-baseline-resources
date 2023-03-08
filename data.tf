
data "azurerm_virtual_machine" "vm" {
  for_each            = { for vm in var.backup_vms : vm.vm_name => vm }
  name                = each.value.vm_name
  resource_group_name = each.value.vm_rg_name
}

data "azurerm_backup_policy_vm" "backup_policy" {
  for_each            = { for vm in var.backup_vms : vm.vm_name => vm }
  name                = each.value.policy_name
  recovery_vault_name = each.value.rsv_name
  resource_group_name = each.value.rsv_rg
}
