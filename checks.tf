# check blocks run after every plan and apply and warn (without blocking) on configuration that would
# quietly misbehave.

# The module does nothing without at least one identity.
check "creates_at_least_one_identity" {
  assert {
    condition     = length(var.user_assigned_identities) > 0
    error_message = "No identities would be created: set user_assigned_identities."
  }
}

# Azure rejects two federated credentials with the same (issuer, subject) on one identity; catch it at
# plan time instead of at the API.
check "issuer_subject_pairs_are_unique" {
  assert {
    condition     = length(local.issuer_subject_pairs) == length(distinct(local.issuer_subject_pairs))
    error_message = "Two or more federated credentials on the same identity share an (issuer, subject) pair; Azure requires the pair to be unique per identity."
  }
}

# The non-standard audience is almost always a mistake for workload identity federation.
check "audience_is_standard" {
  assert {
    condition     = alltrue([for k, c in local.federated_credentials : contains(c.audience, "api://AzureADTokenExchange")])
    error_message = "These federated credentials do not include the standard api://AzureADTokenExchange audience: ${join(", ", sort([for k, c in local.federated_credentials : k if !contains(c.audience, "api://AzureADTokenExchange")]))}. Entra ID token exchange expects it unless you know otherwise."
  }
}
