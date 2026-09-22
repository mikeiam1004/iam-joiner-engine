# Runtime Identity Sequence

```mermaid
sequenceDiagram
    autonumber
    participant HR as HR Payload (users.json)
    participant TF as Terraform Engine
    participant IDP as Entra ID / Tenant Directory

    HR->>TF: Load JSON payload via file()
    TF->>TF: Ingest active users & parse ABAC maps
    TF->>IDP: POST /users (Provision Accounts)
    IDP-->>TF: Return Object IDs
```

---

## Mover State Transition Workflow

When an employee changes departments (a "Mover" event), the engine calculates the differences between their old entitlements and new requirements, executing the lifecycle changes below:

```mermaid
sequenceDiagram
    autonumber
    participant HR as HR Data (users.json)
    participant TF as Terraform State Engine
    participant IDP as Entra ID Tenant

    HR->>TF: Send updated Department attribute
    TF->>TF: Calculate Entitlement Delta (Old Group vs New Group)
    TF->>IDP: DELETE /groups/{old_id}/members/{user_id}
    IDP-->>TF: 204 No Content (Access Revoked)
    TF->>IDP: POST /groups/{new_id}/members/{user_id}
    IDP-->>TF: 201 Created (New Access Granted)
```

## Entitlement Delta Strategy & Permission Creep Mitigation

In traditional identity management, when an employee shifts from **Finance** to **Engineering**, they are often added to the Engineering group while their old Finance memberships are forgotten. This accumulates over time as **permission creep**—a major security compliance risk.

Terraform completely eliminates permission creep through **Declarative State Management**:
* **The Desired State Blueprint**: Terraform doesn't look at individual actions; it checks the complete picture. When the department changes to `Engineering`, the *only* target state defined for that user key is membership in the Engineering group.
* **Automatic Eviction (The Delta)**: Because the user's mapping to the Finance group is no longer present in the code, Terraform detects a discrepancy with the live environment. 
* **Atomic Cleanups**: During execution, Terraform isolates this delta and fires an atomic `DELETE` command to tear down the old access right *before or alongside* granting the new one. No stale permissions are ever left behind.

---

## Leaver Offboarding Flow

```mermaid
sequenceDiagram
    autonumber
    participant HR as HR Payload (users.json)
    participant TF as Terraform Engine
    participant IDP as Directory Provider
    participant API as Graph API (Revocation)

    HR->>TF: Set status = "TERMINATED"
    TF->>IDP: PATCH /users/{id} (account_enabled = false)
    TF->>IDP: DELETE /groups/{group_id}/members/{user_id}
    IDP-->>TF: Entitlements Purged
    TF->>API: POST /users/{id}/revokeSignInSessions
    API-->>TF: Refresh Tokens Invalidated (Active Sessions Killed)
```

## SecOps Incident Response Emergency Kill-Switch

If an account must be locked down immediately outside of standard automated HR cycles (such as during a live security incident or active insider threat), Security Operations personnel must bypass Terraform and execute the explicit session revocation command directly via the Azure CLI.

Execute this command to immediately invalidate all active refresh tokens, cookie sessions, and app connections across all corporate endpoints:

```bash
az ad user revoke-sign-in-sessions --id "<target_user_object_id>"
```
