output "federated_identity_credential_audiences" {
  description = "Audiences of the federated identity credentials created by this module"
  value = {
    for k in azurerm_federated_identity_credential.this : k.name => k.audience
  }
}

output "federated_identity_credential_ids" {
  description = "Ids of the federated identity credentials created by this module"
  value = {
    for k in azurerm_federated_identity_credential.this : k.name => k.id
  }
}

output "federated_identity_credential_issuers" {
  description = "Issuers of the federated identity credentials created by this module"
  value = {
    for k in azurerm_federated_identity_credential.this : k.name => k.issuer
  }
}

output "federated_identity_credential_names" {
  description = "Names of the federated identity credentials created by this module"
  value = {
    for k in azurerm_federated_identity_credential.this : k.name => k.name
  }
}

output "federated_identity_credential_parent_ids" {
  description = "Parent ids of the federated identity credentials created by this module"
  value = {
    for k in azurerm_federated_identity_credential.this : k.name => k.parent_id
  }
}

output "federated_identity_credential_subjects" {
  description = "Subjects of the federated identity credentials created by this module"
  value = {
    for k in azurerm_federated_identity_credential.this : k.name => k.subject
  }
}

output "managed_identity_client_ids" {
  description = "Client ids of the user assigned identity ids created by this module"
  value = {
    for k in azurerm_user_assigned_identity.this : k.name => k.client_id
  }
}

output "managed_identity_ids" {
  description = "Ids of the user assigned identity ids created by this module"
  value = {
    for k in azurerm_user_assigned_identity.this : k.name => k.id
  }
}

output "managed_identity_locations" {
  description = "Locations of the user assigned identity ids created by this module"
  value = {
    for k in azurerm_user_assigned_identity.this : k.name => k.location
  }
}

output "managed_identity_names" {
  description = "Names of the user assigned identity ids created by this module"
  value = {
    for k in azurerm_user_assigned_identity.this : k.name => k.name
  }
}

output "managed_identity_principal_ids" {
  description = "Principal ids of the user assigned identity ids created by this module"
  value = {
    for k in azurerm_user_assigned_identity.this : k.name => k.principal_id
  }
}

output "managed_identity_rg_names" {
  description = "Resource group names of the user assigned identity ids created by this module"
  value = {
    for k in azurerm_user_assigned_identity.this : k.name => k.resource_group_name
  }
}
