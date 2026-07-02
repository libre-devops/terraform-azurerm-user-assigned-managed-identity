output "user_assigned_identities" {
  description = "The identities, keyed by name. Full resource objects (all attributes)."
  value       = azurerm_user_assigned_identity.this
}

output "ids" {
  description = "Map of identity name to resource id."
  value       = { for k, i in azurerm_user_assigned_identity.this : k => i.id }
}

output "ids_zipmap" {
  description = "Map of identity name to { name, id }, for easy composition with other modules."
  value       = { for k, i in azurerm_user_assigned_identity.this : k => { name = i.name, id = i.id } }
}

output "names" {
  description = "Map of identity name to name (convenience passthrough)."
  value       = { for k, i in azurerm_user_assigned_identity.this : k => i.name }
}

output "principal_ids" {
  description = "Map of identity name to the service principal object id (what RBAC assignments target)."
  value       = { for k, i in azurerm_user_assigned_identity.this : k => i.principal_id }
}

output "client_ids" {
  description = "Map of identity name to the client (application) id (what workloads authenticate as)."
  value       = { for k, i in azurerm_user_assigned_identity.this : k => i.client_id }
}

output "tenant_ids" {
  description = "Map of identity name to the tenant id the identity belongs to."
  value       = { for k, i in azurerm_user_assigned_identity.this : k => i.tenant_id }
}

output "federated_credentials" {
  description = "The federated credentials, keyed \"identity|credential\". Curated projection (a full-object output would touch the resource's deprecated parent_id / resource_group_name attributes)."
  value = {
    for k, c in azurerm_federated_identity_credential.this : k => {
      id                        = c.id
      name                      = c.name
      user_assigned_identity_id = c.user_assigned_identity_id
      issuer                    = c.issuer
      subject                   = c.subject
      audience                  = c.audience
    }
  }
}

output "federated_credential_ids" {
  description = "Map of \"identity|credential\" to federated credential id."
  value       = { for k, c in azurerm_federated_identity_credential.this : k => c.id }
}

output "resource_group_name" {
  description = "The resource group the identities live in, parsed from resource_group_id."
  value       = local.rg_name
}
