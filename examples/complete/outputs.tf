output "ids" {
  description = "Map of identity name to resource id."
  value       = module.user_assigned_managed_identity.ids
}

output "ids_zipmap" {
  description = "Map of identity name to { name, id }."
  value       = module.user_assigned_managed_identity.ids_zipmap
}

output "principal_ids" {
  description = "Map of identity name to service principal object id."
  value       = module.user_assigned_managed_identity.principal_ids
}

output "client_ids" {
  description = "Map of identity name to client (application) id."
  value       = module.user_assigned_managed_identity.client_ids
}

output "tenant_ids" {
  description = "Map of identity name to tenant id."
  value       = module.user_assigned_managed_identity.tenant_ids
}

output "federated_credential_ids" {
  description = "Map of \"identity|credential\" to federated credential id."
  value       = module.user_assigned_managed_identity.federated_credential_ids
}
