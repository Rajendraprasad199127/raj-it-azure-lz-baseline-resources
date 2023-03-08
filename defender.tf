resource "azurerm_security_center_subscription_pricing" "generic" {
  for_each      = { for r in var.defender_types : r.name => r }
  tier          = "Standard"
  resource_type = each.key
}

resource "azurerm_security_center_auto_provisioning" "security_center_auto_provisioning" {
  auto_provision = "On"
}

resource "azurerm_security_center_workspace" "main" {
  scope        = data.azurerm_subscription.current.id
  workspace_id = data.azurerm_log_analytics_workspace.management.id
}

