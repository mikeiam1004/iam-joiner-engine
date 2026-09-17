# User Schema Specification

## Required Fields
* **`user_id`**: A unique alphanumeric string acting as the primary identity key. Used for building the Terraform resource address map.
* **`email`**: The root string used to parse or verify external account correlation.
* **`department`**: A strict string value matched against the Attribute-Based Access Control (ABAC) map (`Engineering`, `Finance`, `Security`).
* **`status`**: Current employment state. Must be a string equal to `ACTIVE` to trigger resource provisioning.

## String Format Rules
* All field keys and values must be lowercase-keyed and strictly wrapped in string double-quotes (`""`).
* Department fields must strictly match the PascalCase structural keys defined in the `department_group_map` block.

## Default Fallbacks & Missing Keys
* **Missing Keys**: Optional properties not listed above are gracefully accepted but ignored by the processing engine unless explicit fallbacks are designated.
* **Domain Append**: If an absolute UPN is missing from the incoming schema, the engine falls back to generating a UPN by joining the user prefix with the defined `var.domain_name` string.
