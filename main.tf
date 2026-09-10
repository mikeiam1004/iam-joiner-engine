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
