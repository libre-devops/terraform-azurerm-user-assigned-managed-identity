# Plan-time tests for the module. The azurerm provider is mocked, so no credentials, no features
# block, and no cloud calls are needed:
#   terraform init -backend=false && terraform test

mock_provider "azurerm" {
  mock_resource "azurerm_user_assigned_identity" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ldo-uks-tst-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-mock"
    }
  }
}

variables {
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ldo-uks-tst-001"
  location          = "uksouth"
  tags              = { Environment = "tst" }
}

# Identities with merged tags and a federated credential carrying the standard audience default.
run "identities_and_credentials" {
  command = apply

  variables {
    user_assigned_identities = {
      "id-app" = {
        tags = { Component = "app" }
        federated_credentials = {
          github-main = {
            issuer  = "https://token.actions.githubusercontent.com"
            subject = "repo:libre-devops/example:ref:refs/heads/main"
          }
        }
      }
      "id-plain" = {}
    }
  }

  assert {
    condition     = length(azurerm_user_assigned_identity.this) == 2
    error_message = "Both identities should be created."
  }

  assert {
    condition     = azurerm_user_assigned_identity.this["id-app"].tags["Environment"] == "tst" && azurerm_user_assigned_identity.this["id-app"].tags["Component"] == "app"
    error_message = "Module tags and per-identity tags should merge."
  }

  assert {
    condition     = azurerm_federated_identity_credential.this["id-app|github-main"].audience[0] == "api://AzureADTokenExchange"
    error_message = "The federated credential audience should default to api://AzureADTokenExchange."
  }

  assert {
    condition     = azurerm_federated_identity_credential.this["id-app|github-main"].name == "github-main"
    error_message = "The credential name should be the map key."
  }
}

# isolation_scope passes through.
run "isolation_scope_passthrough" {
  command = apply

  variables {
    user_assigned_identities = {
      "id-isolated" = { isolation_scope = "Regional" }
    }
  }

  assert {
    condition     = azurerm_user_assigned_identity.this["id-isolated"].isolation_scope == "Regional"
    error_message = "isolation_scope should pass through."
  }
}

# An invalid isolation_scope is rejected by variable validation.
run "rejects_invalid_isolation_scope" {
  command = plan

  variables {
    user_assigned_identities = {
      "id-bad" = { isolation_scope = "Zonal" }
    }
  }

  expect_failures = [var.user_assigned_identities]
}

# Duplicate (issuer, subject) pairs on one identity trip the uniqueness check.
run "flags_duplicate_issuer_subject" {
  command = plan

  variables {
    user_assigned_identities = {
      "id-app" = {
        federated_credentials = {
          one = {
            issuer  = "https://token.actions.githubusercontent.com"
            subject = "repo:libre-devops/example:ref:refs/heads/main"
          }
          two = {
            issuer  = "https://token.actions.githubusercontent.com"
            subject = "repo:libre-devops/example:ref:refs/heads/main"
          }
        }
      }
    }
  }

  expect_failures = [check.issuer_subject_pairs_are_unique]
}

# A non-standard audience trips the advisory check.
run "flags_non_standard_audience" {
  command = plan

  variables {
    user_assigned_identities = {
      "id-app" = {
        federated_credentials = {
          odd = {
            issuer   = "https://token.actions.githubusercontent.com"
            subject  = "repo:libre-devops/example:ref:refs/heads/main"
            audience = ["api://custom"]
          }
        }
      }
    }
  }

  expect_failures = [check.audience_is_standard]
}
