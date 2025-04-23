resource "azurerm_user_assigned_identity" "this" {
  for_each            = { for k, v in var.user_assigned_managed_identities : k => v }
  resource_group_name = var.rg_name
  location            = var.location
  tags                = var.tags

  name = each.value.name
}

resource "azurerm_federated_identity_credential" "this" {
  for_each            = { for k, v in var.user_assigned_managed_identities : k => v if v.create_federated_credential == true }
  name                = each.value.federated_credential_display_name == null ? "fd-${each.value.name}" : each.value.federated_credential_display_name
  resource_group_name = azurerm_user_assigned_identity.this[each.key].resource_group_name
  parent_id           = azurerm_user_assigned_identity.this[each.key].id
  audience            = each.value.federated_credential_audiences
  issuer              = each.value.federated_credential_issuer
  subject             = each.value.federated_credential_subject
}