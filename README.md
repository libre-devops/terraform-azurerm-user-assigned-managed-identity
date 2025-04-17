```hcl
resource "azurerm_user_assigned_identity" "this" {
  for_each            = { for k, v in var.user_assigned_managed_identities : k => v }
  resource_group_name = var.rg_name
  location            = var.location
  tags                = var.tags

  name = each.value.name
}

resource "azurerm_federated_identity_credential" "this" {
  for_each            = { for k, v in var.user_assigned_managed_identities : k => v if v.create_federated_credential == true }
  name                = each.value.federated_credential_display_name
  resource_group_name = azurerm_user_assigned_identity[each.key].this.resource_group_name
  parent_id           = azurerm_user_assigned_identity[each.key].this.id
  audience            = each.value.federated_credential_audiences
  issuer              = each.value.federated_credential_issuer
  subject             = each.value.federated_credential_subject
}
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

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
| <a name="input_location"></a> [location](#input\_location) | The location for this resource to be put in | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the VNet gateway | `string` | n/a | yes |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use on the resources that are deployed with this module. | `map(string)` | n/a | yes |
| <a name="input_user_assigned_managed_identities"></a> [user\_assigned\_managed\_identities](#input\_user\_assigned\_managed\_identities) | Object to create user assigned managed identities | <pre>list(object({<br/>    name                              = string<br/>    create_federated_credential       = optional(bool, false)<br/>    federated_credential_audiences    = optional(list(string), [])<br/>    federated_credential_display_name = optional(string)<br/>    federated_credential_subject      = optional(string)<br/>    federated_credential_issuer       = optional(string)<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_federated_identity_credential_audiences"></a> [federated\_identity\_credential\_audiences](#output\_federated\_identity\_credential\_audiences) | Audiences of the federated identity credentials created by this module |
| <a name="output_federated_identity_credential_ids"></a> [federated\_identity\_credential\_ids](#output\_federated\_identity\_credential\_ids) | Ids of the federated identity credentials created by this module |
| <a name="output_federated_identity_credential_issuers"></a> [federated\_identity\_credential\_issuers](#output\_federated\_identity\_credential\_issuers) | Issuers of the federated identity credentials created by this module |
| <a name="output_federated_identity_credential_names"></a> [federated\_identity\_credential\_names](#output\_federated\_identity\_credential\_names) | Names of the federated identity credentials created by this module |
| <a name="output_federated_identity_credential_parent_ids"></a> [federated\_identity\_credential\_parent\_ids](#output\_federated\_identity\_credential\_parent\_ids) | Parent ids of the federated identity credentials created by this module |
| <a name="output_federated_identity_credential_subjects"></a> [federated\_identity\_credential\_subjects](#output\_federated\_identity\_credential\_subjects) | Subjects of the federated identity credentials created by this module |
| <a name="output_managed_identity_client_ids"></a> [managed\_identity\_client\_ids](#output\_managed\_identity\_client\_ids) | Client ids of the user assigned identity ids created by this module |
| <a name="output_managed_identity_ids"></a> [managed\_identity\_ids](#output\_managed\_identity\_ids) | Ids of the user assigned identity ids created by this module |
| <a name="output_managed_identity_locations"></a> [managed\_identity\_locations](#output\_managed\_identity\_locations) | Locations of the user assigned identity ids created by this module |
| <a name="output_managed_identity_names"></a> [managed\_identity\_names](#output\_managed\_identity\_names) | Names of the user assigned identity ids created by this module |
| <a name="output_managed_identity_principal_ids"></a> [managed\_identity\_principal\_ids](#output\_managed\_identity\_principal\_ids) | Principal ids of the user assigned identity ids created by this module |
| <a name="output_managed_identity_rg_names"></a> [managed\_identity\_rg\_names](#output\_managed\_identity\_rg\_names) | Resource group names of the user assigned identity ids created by this module |
