package main

# Import modern v1 syntax rules
import rego.v1

# Block plans containing resource deletion actions
deny contains msg if {
	resource := input.resource_changes[_]
	"delete" in resource.change.actions
	msg := sprintf("Resource deletion detected: %v", [resource.address])
}

deny contains msg if {
	resource := input.resource_changes[_]
	resource.type == "azuread_user"
	"create" in resource.change.actions

	# Catch account creation in a disabled state
	resource.change.after.account_enabled == false
	msg := sprintf("IAM Policy Violation: User '%v' created disabled", [resource.address])
}

valid_departments := ["Engineering", "Finance", "Security", "Operations", "Human Resource"]

# Block plans assigning users to non-standard departments
deny contains msg if {
	resource := input.resource_changes[_]
	resource.type == "azuread_user"
	"create" in resource.change.actions

	dept := resource.change.after.department

	# Verify if the department value sits outside the authorized collection
	not dept in valid_departments

	msg := sprintf("Compliance Error: User '%v' assigned invalid department '%v'", [resource.address, dept])
}
