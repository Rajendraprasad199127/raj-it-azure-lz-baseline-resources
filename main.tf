# module for FIM which is installed on arc_subscription

module "defender_cloud_fim" {
  count                        = var.deploy_defender_fim ? 1 : 0
  source                       = "./modules/fim"
  region                       = var.region
  deployment_rg_name           = "rg-${var.opgroup}-${var.region_shortcut[var.region]}-${var.environment}-fim-01"
  log_analytics_workspace_name = data.azurerm_log_analytics_workspace.management.name
  log_analytics_workspace_id   = data.azurerm_log_analytics_workspace.management.id
}

module "policy_exemptions" {
  count                       = var.deploy_policy_exemptions ? 1 : 0
  source                      = "./modules/policy_exemptions"
  policy_exemptions_sub_level = var.policy_exemptions_sub_level
}

module "update_automation" {
  count  = var.deploy_update_automation ? 1 : 0
  source = "./modules/update_automation"

  automation_account_name = var.automation_account_name
  resource_group_name     = var.automation_resource_group_name
  location                = var.region

  schedules               = var.update_automation_schedules
  target_management_group = var.update_automation_target_management_group

  providers = {
    azurerm = azurerm.management
  }
}

module "remediation_tasks" {
  count  = var.deploy_remediation ? 1 : 0
  source = "./modules/remediation_tasks"

  providers = {
    azurerm = azurerm.management
  }
}

# module for Data Protection Backup Vault

module "dpv" {
  for_each        = var.dpvs
  source          = "./modules/dpv"
  region          = each.key
  dpvs            = each.value
  dpv_rg_name     = "rg-${var.opco}-${var.region_shortcut[each.key]}-${var.environment}-dpv-01"
  dpv_policy_name = "plc-${var.opco}-${var.region_shortcut[each.key]}-${var.environment}"
}

# module for Recovery Services Vault

module "rsv" {
  for_each        = var.rsvs
  source          = "./modules/rsv"
  rsvs            = each.value
  region          = each.key
  rsv_rg_name     = "rg-${var.opco}-${var.region_shortcut[each.key]}-${var.environment}-rsv-01"
  rsv_policy_name = "plc-${var.opco}-${var.region_shortcut[each.key]}-${var.environment}"
}



module "alerts" {
  count                           = var.deploy_alerts ? 1 : 0
  source                          = "./modules/alerts"
  log_alerts                      = var.log_alerts
  action_group                    = var.action_group
  region                          = var.region
  alert_rg_name                   = "rg-${var.opgroup}-${var.region_shortcut[var.region]}-${var.environment}-alert-01"
  alert_group_resource_group_name = var.alert_group_resource_group_name

  providers = {
    azurerm.management = azurerm.management
    azurerm            = azurerm
  }
}

# module for avs enablement

module "avs" {
  count  = var.avs_enabled ? 1 : 0
  source = "./modules/avs"

  providers = {
    azurerm = azurerm.provider_registration
  }
}

module "KQL" {
  source   = "./modules/scheduled_kql_query"
  for_each = { for kql in var.KQL : kql.name => kql }
  name     = each.key
  KQL      = each.value.kql
  rg_name  = "rg-${var.opgroup}-${var.region_shortcut[var.region]}-${var.environment}-logicapp-01"
  region   = var.region
  depends_on = [
    azurerm_resource_group.rg_logicapp
  ]
}

module "asr" {
  source             = "./modules/asr"
  for_each           = { for asr in var.asr : asr.asr_rsv_name => asr }
  storage_cache_rg   = each.value.storage_cache_rg
  primary_region     = each.value.primary_region
  secondary_region   = each.value.secondary_region
  secondary_rg_name  = each.value.secondary_rg_name
  asr_rsv_name       = each.key
  storage_cache_name = each.value.storage_cache_name
  vnets              = each.value.vnets
  providers = {
    azurerm.primary   = azurerm
    azurerm.secondary = azurerm.failover
  }

}

module "replicated_vm" {
  for_each                    = { for repl in var.replicated_vm : repl.primary_vnet_name => repl }
  source                      = "./modules/replicated_vm"
  rsv_name                    = each.value.rsv_name
  secondary_rg                = each.value.secondary_rg
  vms                         = each.value.vms
  source_fabric_name          = module.asr[each.value.rsv_name].primary_fabric_name
  target_fabric_name          = module.asr[each.value.rsv_name].secondary_fabric_name
  policy_id                   = module.asr[each.value.rsv_name].policy_id
  source_protection_container = module.asr[each.value.rsv_name].source_protection_container
  target_fabric_id            = module.asr[each.value.rsv_name].target_fabric_id
  target_container_id         = module.asr[each.value.rsv_name].target_container_id
  staging_storage             = module.asr[each.value.rsv_name].staging_storage
  primary_vnet_name           = each.key
  secondary_vnet_id           = module.asr[each.value.rsv_name].secondary_vnet_ids[0][each.value.secondary_vnet_name].id
  primary_vnet_rg             = each.value.primary_vnet_rg

  providers = {
    azurerm.primary   = azurerm
    azurerm.secondary = azurerm.failover
  }
  depends_on = [
    module.asr
  ]
}

module "storage_account" {
  for_each                  = { for storage_account in var.storage_account_list : storage_account.opco_prefix => storage_account }
  source                    = "./modules/storage_account"
  current_index             = index(var.storage_account_list, each.value) + 1
  location                  = each.value.location
  location_shortname        = lookup(var.region_shortcut, each.value.location)
  opco                      = each.value.opco
  opco_prefix               = each.value.opco_prefix
  cloud_suffix              = each.value.cloud_suffix
  environment               = each.value.environment
  settings                  = each.value.settings
  file_shares               = each.value.file_shares
  containers_list           = each.value.containers_list
  service_endpoint_settings = each.value.service_endpoint_settings
  ip_rules                  = each.value.ip_rules
  providers = {
    azurerm = azurerm
  }
  depends_on = [
    local.storage_account_module_dependency
  ]
}

module "kv" {
  for_each    = var.kvs
  source      = "./modules/key_vault"
  kvs         = each.value
  region      = each.key
  kv_rgs_name = "rg-${var.opco}-${lookup(var.region_shortcut, each.key)}-${var.environment}-${var.service}-kv-01"
}

module "bastion" {
  for_each            = { for bastion in var.bastion_list : bastion.resource_group_name => bastion }
  source              = "./modules/bastion"
  instance_number     = index(var.bastion_list, each.value) + 1
  location            = var.region
  resource_group_name = each.value.resource_group_name
  opgroup             = var.opgroup
  opco                = var.opco
  service_name        = each.value.service_name
  environment_short   = var.environment
  environment         = var.environment
  location_shortname  = lookup(var.region_shortcut, var.region)
  bastion_vnet        = each.value.vnet_settings
  bastion_rbacs       = each.value.rbacs
  depends_on = [
    module.rg,
    module.network
  ]
}

# module for AFS (Azure File Sync) Resources
module "afs" {
  for_each                = { for afs in var.afs_resource_list : afs.opco_prefix => afs }
  source                  = "./modules/AFS"
  storage_sync_group_list = each.value.storage_sync_group_list
  storage_sync            = each.value.storage_sync
  opco_prefix             = each.value.opco_prefix
  location                = each.value.location
  location_shortname      = lookup(var.region_shortcut, each.value.location)
  environment             = var.environment
  opco                    = var.opco
  storage_account_id      = each.value.storage_account_id
  providers = {
    azurerm = azurerm
  }
}