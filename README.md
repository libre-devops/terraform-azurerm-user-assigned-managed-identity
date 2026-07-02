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
regionally isolated identities (the provider accepts only Regional; leave it unset otherwise).

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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0, < 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_federated_identity_credential.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Azure region for the identities. | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | Resource id of the resource group to create the identities in. The name is parsed from it (pass the rg module's ids output). | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to every identity (merged with any per-identity tags). | `map(string)` | `{}` | no |
| <a name="input_user_assigned_identities"></a> [user\_assigned\_identities](#input\_user\_assigned\_identities) | The user-assigned managed identities to create, keyed by identity name. Each identity optionally<br/>carries federated credentials (keyed by credential name) for workload identity federation: an external<br/>OIDC issuer (GitHub Actions, Kubernetes, and so on) exchanges its own token for this identity, no<br/>client secret involved. audience defaults to the standard api://AzureADTokenExchange. Azure requires<br/>the (issuer, subject) pair to be unique across an identity's credentials.<br/><br/>isolation\_scope opts an identity into regional isolation (failure containment for regionally isolated<br/>services); leave it unset for the standard behaviour. | <pre>map(object({<br/>    tags            = optional(map(string))<br/>    isolation_scope = optional(string)<br/><br/>    federated_credentials = optional(map(object({<br/>      issuer   = string<br/>      subject  = string<br/>      audience = optional(list(string), ["api://AzureADTokenExchange"])<br/>    })), {})<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_ids"></a> [client\_ids](#output\_client\_ids) | Map of identity name to the client (application) id (what workloads authenticate as). |
| <a name="output_federated_credential_ids"></a> [federated\_credential\_ids](#output\_federated\_credential\_ids) | Map of "identity\|credential" to federated credential id. |
| <a name="output_federated_credentials"></a> [federated\_credentials](#output\_federated\_credentials) | The federated credentials, keyed "identity\|credential". Full resource objects. |
| <a name="output_ids"></a> [ids](#output\_ids) | Map of identity name to resource id. |
| <a name="output_ids_zipmap"></a> [ids\_zipmap](#output\_ids\_zipmap) | Map of identity name to { name, id }, for easy composition with other modules. |
| <a name="output_names"></a> [names](#output\_names) | Map of identity name to name (convenience passthrough). |
| <a name="output_principal_ids"></a> [principal\_ids](#output\_principal\_ids) | Map of identity name to the service principal object id (what RBAC assignments target). |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group the identities live in, parsed from resource\_group\_id. |
| <a name="output_tenant_ids"></a> [tenant\_ids](#output\_tenant\_ids) | Map of identity name to the tenant id the identity belongs to. |
| <a name="output_user_assigned_identities"></a> [user\_assigned\_identities](#output\_user\_assigned\_identities) | The identities, keyed by name. Full resource objects (all attributes). |
<!-- END_TF_DOCS -->
