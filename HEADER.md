<!--
  Keep the title and badges OUTSIDE the centered <div>: the Terraform Registry's markdown renderer
  does not parse markdown inside an HTML block, so a # heading or [![badge]] in the div renders as
  literal text on the registry. Only the logo (HTML) goes in the div.
-->
<div align="center">
  <a href="https://libredevops.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://libredevops.org/assets/libre-devops-white.png">
      <img alt="Libre DevOps" src="https://libredevops.org/assets/libre-devops-black.png" width="300">
    </picture>
  </a>
</div>

# Terraform Azure User Assigned Managed Identity

User-assigned managed identities with federated credentials, so workloads authenticate without a
single client secret.

[![CI](https://github.com/libre-devops/terraform-azurerm-user-assigned-managed-identity/actions/workflows/ci.yml/badge.svg)](https://github.com/libre-devops/terraform-azurerm-user-assigned-managed-identity/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/libre-devops/terraform-azurerm-user-assigned-managed-identity?sort=semver&label=release)](https://github.com/libre-devops/terraform-azurerm-user-assigned-managed-identity/releases/latest)
[![Terraform Registry](https://img.shields.io/badge/registry-libre--devops-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/namespaces/libre-devops)
[![License](https://img.shields.io/github/license/libre-devops/terraform-azurerm-user-assigned-managed-identity)](./LICENSE)

---

## Overview

Identities keyed by name, each optionally carrying **federated credentials** (keyed by credential
name) for workload identity federation: an external OIDC issuer (GitHub Actions, Kubernetes service
accounts, and so on) exchanges its own token for the identity, so no client secret ever exists. The
audience defaults to the standard `api://AzureADTokenExchange`, and a plan-time check catches the
duplicate (issuer, subject) pairs Azure would reject at the API. `isolation_scope` is exposed for
regionally isolated identities.

Outputs cover everything composition needs: `principal_ids` (what RBAC assignments target, pairs with
the `role-assignment` module), `client_ids` (what workloads authenticate as), `tenant_ids`, plus ids,
zipmap, and the full resource objects. The resource group is passed by id and parsed.

## Usage

```hcl
module "user_assigned_managed_identity" {
  source  = "libre-devops/user-assigned-managed-identity/azurerm"
  version = "~> 4.0"

  resource_group_id = module.rg.ids["rg-ldo-uks-prd-001"]
  location          = "uksouth"
  tags              = module.tags.tags

  user_assigned_identities = {
    "id-ldo-ci-uks-prd-001" = {
      federated_credentials = {
        github-main = {
          issuer  = "https://token.actions.githubusercontent.com"
          subject = "repo:libre-devops/my-repo:ref:refs/heads/main"
        }
      }
    }
  }
}
```

## Examples

- [`examples/minimal`](./examples/minimal) - one identity, required inputs only.
- [`examples/complete`](./examples/complete) - the full surface: a CI identity with two GitHub Actions
  federated credentials, per-identity tags, and an explicit isolation scope.

## Developing

Local work needs **PowerShell 7+** and **[`just`](https://github.com/casey/just)**, because the recipes
wrap the [LibreDevOpsHelpers](https://www.powershellgallery.com/packages/LibreDevOpsHelpers)
PowerShell module (the same engine the `libre-devops/terraform-azure` action runs in CI). Install
just with `brew install just`, or `uv tool add rust-just` then `uv run just <recipe>`.

Run `just` to list recipes: `just update-ldo-pwsh` (install or force-update LibreDevOpsHelpers from
PSGallery), `just validate`, `just scan` (Trivy only), `just pwsh-analyze` (PSScriptAnalyzer only),
`just plan`, `just apply`, `just destroy`, `just e2e`, `just test`, and `just docs` (the
plan/apply/destroy recipes mirror the action, including the storage firewall dance; `just e2e`
applies an example then always destroys it, defaulting to `minimal`, so nothing is left running).
Releasing is also `just`:
`just increment-release [patch|minor|major]` bumps, tags, and publishes a GitHub release, and the
Terraform Registry picks up the tag.

## Security scan exceptions

This module is scanned with [Trivy](https://github.com/aquasecurity/trivy); HIGH and CRITICAL
findings fail the build. Any waiver is a deliberate, reviewed decision, never a way to quiet a
finding that should be fixed. Waivers live in [`.trivyignore.yaml`](./.trivyignore.yaml) (the
machine-applied source of truth, passed to Trivy with `--ignorefile`) and are mirrored in a table
here so the reason is auditable.

There are currently **no exceptions**: the module and its examples scan clean. Federated credentials
exist to REMOVE standing secrets, so there is nothing to waive.

To add an exception: add an entry to `.trivyignore.yaml` (`id`, optional `paths` to scope it, and a
`statement` recording why), then add a matching row here recording the reason. Both the file and
the table are reviewed in the pull request.

## Reference

The Requirements, Providers, Inputs, Outputs, and Resources below are generated by `terraform-docs`.
