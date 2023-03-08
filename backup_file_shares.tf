resource "azurerm_backup_protected_file_share" "share" {
  for_each                  = { for share in var.backup_file_shares : share.share_name => share }
  resource_group_name       = each.value.rsv_rg
  recovery_vault_name       = each.value.rsv_name
  source_storage_account_id = each.value.source_storage_account_id
  source_file_share_name    = each.key
  backup_policy_id          = data.azurerm_backup_policy_file_share.policy[each.key].id
}

data "azurerm_backup_policy_file_share" "policy" {
  for_each            = { for share in var.backup_file_shares : share.share_name => share }
  name                = each.value.policy_name
  recovery_vault_name = each.value.rsv_name
  resource_group_name = each.value.rsv_rg
}