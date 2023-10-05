/**
 * # AWS Organizations terraform module
 *
 * This module is able to create and manage AWS organization, accounts, 
 * units and policies
 *
 * Module itself creates an AWS organization and manages additional resources
 * using submodules, placed in `./modules` directory
 * 
 */

# resource "aws_organizations_organization" "this_organizations_organization" {
#   feature_set = "ALL"

#   # List of AWS service principal names for which you want to enable integration with your organization
#   aws_service_access_principals = var.aws_service_access_principals

#   enabled_policy_types = var.enabled_policy_types
# }

module "this_policies" {
  for_each = var.policies

  source  = "./modules/organizations-policy"
  context = module.this.context

  # Compulsory parameters
  name           = each.value["Name"]
  policy_content = file(each.value["Policy"])
  # Optional parameters
  description = each.value["Description"]
}

resource "aws_organizations_policy_attachment" "Prod" {

  policy_id = module.this_policies["Prod_policy"].id
  target_id = module.organization_units_Prod_Non_Prod["Prod-OU"].id

  depends_on = [
    module.this_policies,
    module.organization_units_Prod_Non_Prod

  ]
}
resource "aws_organizations_policy_attachment" "Non_Prod" {

  policy_id = module.this_policies["Non_Prod_policy"].id
  target_id = module.organization_units_Prod_Non_Prod["Non-Prod-OU"].id

  depends_on = [
    module.this_policies,
    module.organization_units_Prod_Non_Prod

  ]
}

# # Create AWS account assigned to root
# module "this_root_accounts" {
#   for_each = var.root_accounts

#   source  = "./modules/account"
#   context = module.this.context

#   # Compulsory parameters
#   email     = each.value.email
#   name      = lookup(each.value, "name", each.key)
#   parent_id = resource.aws_organizations_organization.this_organizations_organization.roots[0].id

#   # Optional parameters
#   role_name                  = lookup(each.value, "role_name", "organization-admin")
#   close_on_deletion          = lookup(each.value, "close_on_deletion", true)
#   iam_user_access_to_billing = lookup(each.value, "iam_user_access_to_billing", "ALLOW")
#   attached_policies          = can(each.value["attached_policies"]) ? flatten([for p in each.value.attached_policies : [for k, v in module.this_policies : v.id if k == p]]) : []

#   depends_on = [
#     aws_organizations_organization.this_organizations_organization,
#     module.this_policies
#   ]
# }

# Create AWS Organizational Units and child AWS accounts
module "organization_units_Prod_Non_Prod" {
  for_each = var.organizational_units  

  source  = "./modules/organizational-unit"
  context = module.this.context

  # Compulsory parameters
  name      = each.key
  parent_id = data.aws_organizations_organization.Name.roots[0].id


  depends_on = [
    module.this_policies
  ]
}

