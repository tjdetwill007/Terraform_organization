data "aws_organizations_organization" "Name" {
  
}

output "name" {
  value = data.aws_organizations_organization.Name.roots[0].id
}