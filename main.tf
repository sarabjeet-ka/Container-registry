locals {
  user_identity_id = each.value.use_user_assigned_identity?data.azurerm_user_assigned_identity.example.id:null

  identity_ids = {
    for k,v in var.acr_variables : k => {
      type = k.use_system_assigned_identity && k.use_user_assigned_identity ? "SystemAssigned, UserAssigned" :
             k.use_system_assigned_identity ? "SystemAssigned" :
             k.use_user_assigned_identity ? "UserAssigned" : ""
      identity_ids = k.use_user_assigned_identity ? [local.user_identity_id] : []
    }
  }
}


data "azurerm_user_assigned_identity" "example" {
    for_each=var.acr_variables
  name                = each.value.user_identity_name
  resource_group_name = each.value.resource_group_name_user_identity

}

resource "azurerm_container_registry" "container_registry" {
for_each = var.acr_variables
name = each.value.container_registry_name
resource_group_name=each.value.resource_group_name_container
location = each.value.location
sku=each.value.sku
admin_enabled=each.value.admin_enabled
public_network_access_enabled=each.value.public_network_access_enabled
quarantine_policy_enabled=each.value.quarantine_policy_enabled
retention_policy_in_days=each.value.retention_policy_in_days
trust_policy_enabled=each.value.trust_policy_enabled
zone_redundancy_enabled=each.value.zone_redundancy_enabled
export_policy_enabled=each.value.export_policy_enabled
anonymous_pull_enabled=each.value.anonymous_pull_enabled
data_endpoint_enabled=each.value.data_endpoint_enabled


identity { 
    type = local.identity_ids[each.key].type 
    identity_ids = local.identity_ids[each.key].identity_ids

}
 }
}