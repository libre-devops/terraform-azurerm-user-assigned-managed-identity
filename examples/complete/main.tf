locals {
  location = lookup(var.regions, var.loc, "uksouth")
  rg_name  = "rg-${var.short}-${var.loc}-${terraform.workspace}-002"
}

module "tags" {
  source  = "libre-devops/tags/azurerm"
  version = "~> 4.0"

  cost_centre     = "1888/67"
  owner           = "platform@example.com"
  deployed_branch = var.deployed_branch
  deployed_repo   = var.deployed_repo
  additional_tags = { Application = "terraform-azurerm-user-assigned-managed-identity" }
}

module "rg" {
  source  = "libre-devops/rg/azurerm"
  version = "~> 4.0"

  resource_groups = [{ name = local.rg_name, location = local.location, tags = module.tags.tags }]
}

# Complete call: the full surface. A CI identity carrying two GitHub Actions federated credentials
# (workload identity federation: the runner's OIDC token is exchanged for the identity, no client
# secret), a workload identity with per-identity tags and an explicit isolation scope, and a plain
# identity with nothing optional set.
module "user_assigned_managed_identity" {
  source = "../../"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  user_assigned_identities = {
    "id-${var.short}-ci-${var.loc}-${terraform.workspace}-002" = {
      tags = { Component = "ci" }
      federated_credentials = {
        github-main = {
          issuer  = "https://token.actions.githubusercontent.com"
          subject = "repo:libre-devops/terraform-azurerm-user-assigned-managed-identity:ref:refs/heads/main"
        }
        github-pull-requests = {
          issuer  = "https://token.actions.githubusercontent.com"
          subject = "repo:libre-devops/terraform-azurerm-user-assigned-managed-identity:pull_request"
        }
      }
    }

    "id-${var.short}-app-${var.loc}-${terraform.workspace}-002" = {
      tags            = { Component = "app" }
      isolation_scope = "None"
    }

    "id-${var.short}-plain-${var.loc}-${terraform.workspace}-002" = {}
  }
}
