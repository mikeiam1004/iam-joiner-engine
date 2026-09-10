locals {
  raw_users = jsondecode(file("${path.module}/users.json"))

  # Filter for active identities only
  active_users = {
    for user in local.raw_users : user.user_id => user
    if user.status == "ACTIVE"
  }

  # Map department strings to target directory security groups
  department_group_map = {
    "Engineering" = "sec-grp-engineering-dept"
    "Finance"     = "sec-grp-finance-dept"
    "Security"    = "sec-grp-secops-dept"
  }
}
