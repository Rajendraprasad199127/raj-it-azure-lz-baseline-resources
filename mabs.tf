module "mabs" {
  for_each = var.mabs_configuration
  source   = "./modules/mabs"
  providers = {
    azurerm.connectivity_source = azurerm.management
    azurerm.keyvault_source     = azurerm.management
  }
  region                                 = each.key
  key_vault_id                           = each.value.key_vault_id
  log_analytics_workspace_id             = data.azurerm_log_analytics_workspace.management.workspace_id
  log_analytics_workspace_key            = data.azurerm_log_analytics_workspace.management.primary_shared_key
  connectivity_vnet_name                 = each.value.connectivity_vnet_name
  connectivity_vnet_id                   = each.value.connectivity_vnet_id
  connectivity_vnet_resource_group_name  = each.value.connectivity_vnet_resource_group_name
  dns_link_network_ids                   = each.value.dns_link_network_ids
  resource_group_name                    = each.value.resource_group_name
  network_resource_group_name            = each.value.network_resource_group_name
  grs_recovery_vault_name                = each.value.grs_recovery_vault_name
  lrs_recovery_vault_name                = each.value.lrs_recovery_vault_name
  vnet_name                              = each.value.vnet_name
  vnet_address_space                     = each.value.vnet_address_space
  vnet_default_gateway                   = each.value.vnet_default_gateway
  mabs_subnet_name                       = each.value.mabs_subnet_name
  mabs_subnet_address_space              = each.value.mabs_subnet_address_space
  mabs_nsg_name                          = each.value.mabs_nsg_name
  mabs_server_name                       = each.value.mabs_server_name
  mabs_dns_servers                       = each.value.mabs_dns_servers
  gateway_subnet_address_space           = each.value.gateway_subnet_address_space
  expressroute_gateway_public_ip_name    = each.value.expressroute_gateway_public_ip_name
  expressroute_gateway_name              = each.value.expressroute_gateway_name
  expressroute_gateway_circuit_id        = each.value.expressroute_gateway_circuit_id
  expressroute_gateway_authorisation_key = each.value.expressroute_gateway_authorisation_key
  mabs_data_disks                        = each.value.mabs_data_disks
  mabs_data_disk_satypes                 = each.value.mabs_data_disk_satypes
}


module "mabspub" {
  for_each = var.mabspub_configuration
  source   = "./modules/mabs.pub"
  providers = {
    azurerm.connectivity_source = azurerm.management
    azurerm.keyvault_source     = azurerm.management
  }
  region                                = each.key
  key_vault_id                          = each.value.key_vault_id
  log_analytics_workspace_id            = data.azurerm_log_analytics_workspace.management.workspace_id
  log_analytics_workspace_key           = data.azurerm_log_analytics_workspace.management.primary_shared_key
  connectivity_vnet_name                = each.value.connectivity_vnet_name
  connectivity_vnet_id                  = each.value.connectivity_vnet_id
  connectivity_vnet_resource_group_name = each.value.connectivity_vnet_resource_group_name
  resource_group_name                   = each.value.resource_group_name
  network_resource_group_name           = each.value.network_resource_group_name
  grs_recovery_vault_name               = each.value.grs_recovery_vault_name
  vnet_name                             = each.value.vnet_name
  vnet_address_space                    = each.value.vnet_address_space
  vnet_default_gateway                  = each.value.vnet_default_gateway
  mabs_subnet_name                      = each.value.mabs_subnet_name
  mabs_subnet_address_space             = each.value.mabs_subnet_address_space
  mabs_nsg_name                         = each.value.mabs_nsg_name
  mabs_server_name                      = each.value.mabs_server_name
  mabs_dns_servers                      = each.value.mabs_dns_servers
  mabs_data_disks                       = each.value.mabs_data_disks
  mabs_data_disk_satypes                = each.value.mabs_data_disk_satypes
}
