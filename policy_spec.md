# Cloud Identity Security Policy Specification

This document details the OPA / Rego policy guardrails implemented within the Joiner-Mover-Leaver (JML) provisioning pipeline engine.

## Policy Rules Architecture

### 1. Resource Deletion Guardrail

- **Objective:** Prevents accidental catastrophic destruction of directory groups or active user objects.
- **Failure Condition:** Triggers if any infrastructure state modification action vector contains the `"delete"` element.

### 2. Initial State Account Lockout Verification

- **Objective:** Ensures no identity accounts are pre-staged or left in an unsafe dormant/disabled creation layout unless explicitly designated for termination.
- **Failure Condition:** Triggers if an identity's deployment action is `"create"` while `account_enabled` evaluates to `false`.

### 3. Attribute-Based Access Control (ABAC) Compliance Check

- **Objective:** Restricts user profiles exclusively to authorized enterprise organizational nodes.
- **Authorized Scopes:** `["Engineering", "Finance", "Security", "Operations"]`
- **Failure Condition:** Triggers if an incoming payload contains a department string that falls outside this explicit array block.

## Local CLI Invocation Syntax

To format governance syntax files and perform a localized compliance simulation check before pushing changes to the remote repository, execute the following CLI tools:

```bash
# 1. Format Rego policy style structures cleanly
opa fmt -w policy/

# 2. Run automated validation checks against a generated Terraform JSON state plan
conftest test tfplan.json --policy policy/
```
