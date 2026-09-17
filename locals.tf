locals {
  raw_users = jsondecode(file("${path.module}/users.json"))

  # Filter for active identities only
  active_users = {
    for user in local.raw_users : user.user_id => user
    if user.status == "ACTIVE"
  }

  # Map department strings to target directory security groups
  department_group_map = {
    "Engineering"    = "sec-grp-engineering-dept"
    "Finance"        = "sec-grp-finance-dept"
    "Security"       = "sec-grp-secops-dept"
    "Human Resource" = "sec-grp-finance-dept"
  }
}

locals {
  # Create flat map linking user IDs to required department groups
  user_group_bindings = {
    for user_key, user in local.active_users : user_key => {
      user_key   = user_key
      department = user.department
      group_key  = user.department
    }
  }
}

locals {
  default_group = "sec-grp-baseline-access"

  # Validates department existence, falls back to baseline if unknown
  validated_bindings = {
    for user_key, user in local.active_users : user_key => {
      group_key = contains(keys(local.department_group_map), user.department) ? user.department : "Baseline"
    }
  }
}
