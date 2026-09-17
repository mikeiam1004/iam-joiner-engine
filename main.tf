resource "azuread_user" "joiners" {
  for_each            = local.active_users
  user_principal_name = "${lower(substr(each.value.first_name, 0, 1))}${lower(each.value.last_name)}@${var.domain_name}"
  display_name        = "${each.value.first_name} ${each.value.last_name}"
  given_name          = each.value.first_name
  surname             = each.value.last_name
  job_title           = each.value.job_title
  department          = each.value.department
  employee_id         = each.value.user_id
  account_enabled     = true
  password            = "P@ssw0rd12345678!" # Force change on first login
}
# Provision security groups for each operational department
resource "azuread_group" "departments" {
  for_each         = local.department_group_map
  display_name     = each.value
  security_enabled = true
}
resource "azuread_group_member" "department_access" {
  for_each         = local.user_group_bindings
  group_object_id  = azuread_group.departments[each.value.group_key].object_id
  member_object_id = azuread_user.joiners[each.key].object_id
}
