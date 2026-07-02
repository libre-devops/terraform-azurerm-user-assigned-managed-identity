locals {
  rg      = provider::azurerm::parse_resource_id(var.resource_group_id)
  rg_name = local.rg.resource_group_name

  # One instance per (identity, credential), keyed "identity|credential". Keys derive from input map
  # keys only, so they stay known at plan time.
  federated_credentials = {
    for item in flatten([
      for identity_name, identity in var.user_assigned_identities : [
        for cred_name, cred in identity.federated_credentials : {
          key           = "${identity_name}|${cred_name}"
          identity_name = identity_name
          cred_name     = cred_name
          issuer        = cred.issuer
          subject       = cred.subject
          audience      = cred.audience
        }
      ]
    ]) : item.key => item
  }

  # (issuer, subject) pairs per identity, for the uniqueness check (Azure rejects duplicates).
  issuer_subject_pairs = [
    for k, c in local.federated_credentials : "${c.identity_name}|${c.issuer}|${c.subject}"
  ]
}

resource "azurerm_user_assigned_identity" "this" {
  for_each = var.user_assigned_identities

  resource_group_name = local.rg_name
  location            = var.location
  tags                = merge(var.tags, coalesce(each.value.tags, {}))
  name                = each.key

  isolation_scope = each.value.isolation_scope
}

# Workload identity federation: an external OIDC token (matching issuer/subject/audience) is exchanged
# for this identity, so no client secret ever exists.
resource "azurerm_federated_identity_credential" "this" {
  for_each = local.federated_credentials

  resource_group_name = local.rg_name
  name                = each.value.cred_name

  user_assigned_identity_id = azurerm_user_assigned_identity.this[each.value.identity_name].id
  issuer                    = each.value.issuer
  subject                   = each.value.subject
  audience                  = each.value.audience
}
