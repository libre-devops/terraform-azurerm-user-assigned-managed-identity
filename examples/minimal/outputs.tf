output "ids" {
  description = "Map of identity name to resource id."
  value       = module.user_assigned_managed_identity.ids
}

output "principal_ids" {
  description = "Map of identity name to service principal object id."
  value       = module.user_assigned_managed_identity.principal_ids
}

output "client_ids" {
  description = "Map of identity name to client (application) id."
  value       = module.user_assigned_managed_identity.client_ids
}
