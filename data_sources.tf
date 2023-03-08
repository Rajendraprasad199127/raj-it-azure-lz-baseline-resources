data "azurerm_subscription" "current" {}

data "azurerm_log_analytics_workspace" "management" {
  provider            = azurerm.management
  name                = var.la_name
  resource_group_name = var.la_rg
}