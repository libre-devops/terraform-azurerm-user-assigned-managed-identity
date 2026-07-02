variable "resource_group_id" {
  description = "Resource id of the resource group to create the identities in. The name is parsed from it (pass the rg module's ids output)."
  type        = string

  validation {
    condition     = try(provider::azurerm::parse_resource_id(var.resource_group_id).resource_type, "") == "resourceGroups"
    error_message = "resource_group_id must be a resource group id of the form /subscriptions/<sub>/resourceGroups/<name>."
  }
}

variable "location" {
  description = "Azure region for the identities."
  type        = string
}

variable "tags" {
  description = "Tags applied to every identity (merged with any per-identity tags)."
  type        = map(string)
  default     = {}
}

variable "user_assigned_identities" {
  description = <<DESC
The user-assigned managed identities to create, keyed by identity name. Each identity optionally
carries federated credentials (keyed by credential name) for workload identity federation: an external
OIDC issuer (GitHub Actions, Kubernetes, and so on) exchanges its own token for this identity, no
client secret involved. audience defaults to the standard api://AzureADTokenExchange. Azure requires
the (issuer, subject) pair to be unique across an identity's credentials.

isolation_scope opts an identity into regional isolation (failure containment for regionally isolated
services); leave it unset for the standard behaviour.
DESC

  type = map(object({
    tags            = optional(map(string))
    isolation_scope = optional(string)

    federated_credentials = optional(map(object({
      issuer   = string
      subject  = string
      audience = optional(list(string), ["api://AzureADTokenExchange"])
    })), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for i in values(var.user_assigned_identities) : i.isolation_scope == null || coalesce(i.isolation_scope, "Regional") == "Regional"])
    error_message = "isolation_scope, when set, must be Regional (leave it unset for the standard behaviour; the provider accepts no other value)."
  }

  validation {
    condition = alltrue(flatten([
      for i in values(var.user_assigned_identities) : [
        for c in values(i.federated_credentials) : c.issuer != "" && c.subject != ""
      ]
    ]))
    error_message = "Every federated credential must set a non-empty issuer and subject."
  }
}
