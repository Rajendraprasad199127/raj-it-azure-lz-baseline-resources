locals {
  tags = {
    Environment : var.environment
  }
  # This environment short mapping is for future use where we want to use a proper environment name for tags
  environment_short = {
    p = "w"
    x = "y"
    s = "x"
    d = "z"
  }
  subscription_role_assignments_list = flatten([
    for role_definition_name, members in var.subscription_role_assignments : [
      for member in members : [{
        resource_id          = "${data.azurerm_subscription.current.id}/Microsoft.Authorization/roleAssignments/${uuidv5(uuidv5("url", role_definition_name), member)}"
        principal_id         = member
        role_definition_name = role_definition_name
      }]
    ]
  ])
  subscription_role_assignments_by_member = {
    for member in local.subscription_role_assignments_list :
    member.resource_id => member
  }

  # We need to add a explicit dependency on network module if there are service endpoint settings were passed in storage account list
  # Since Terraform does not support dynamic expression in Depends On section, hence this approach is used. 
  storage_account_module_dependency = var.storage_account_list[*].service_endpoint_settings != null ? [module.network] : []
}
