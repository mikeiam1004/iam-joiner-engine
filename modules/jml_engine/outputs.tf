output "terminated_user_audit" {
  description = "Audit state for offboarded identities"
  value = {
    for user_id, user in local.terminated_users : user_id => {
      display_name    = azuread_user.lifecycle[user_id].display_name
      account_enabled = azuread_user.lifecycle[user_id].account_enabled
      object_id       = azuread_user.lifecycle[user_id].object_id
    }
  }
}
