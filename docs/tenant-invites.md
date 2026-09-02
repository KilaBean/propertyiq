# Tenant invites & password recovery

How a tenant gets an account, and why no one but the tenant ever knows their
password.

## Why it works this way

Tenants never self-register. A manager assigns a tenant to a unit, and that act
creates the account. The first version of this flow generated a temporary
password server-side and returned it to the manager to pass along.

That was replaced. It meant the manager permanently held a working credential
for their tenant's account — enough to sign in as them and read their
maintenance history — with nothing in the audit trail to show it. Nothing
expired it, and nothing forced the tenant to rotate it.

Now the tenant sets their own password from a link emailed to them. The invite
function returns no credential, and neither does the reset function.

## The flow

```
Manager fills the "Assign tenant" form
        │
        ▼
invite-tenant (Edge Function)
        │  1. manages_unit()  — authorize BEFORE creating anything
        │  2. inviteUserByEmail() — Supabase emails the tenant
        │  3. create_tenancy() — link the tenancy by email
        │     └─ on failure: deleteUser() rolls back the account we created
        ▼
Tenant taps the link in their email
        │
        ▼
propertyiq://login-callback
        │  supabase_flutter consumes the deep link, session established,
        │  onAuthStateChange fires passwordRecovery
        ▼
PasswordRecovery provider flips true → router pins /set-password
        │
        ▼
Tenant chooses a password → resolve() → router releases them to /my-unit
```

If the address already has a PropertyIQ account, no email is sent: the existing
user is simply linked to the new tenancy (`invited: false`).

## Required project configuration

These are environment concerns, not code. The flow will not work without them.

### 1. SMTP

The built-in Supabase email sender is rate limited (a couple of messages an
hour) and is not intended for production. Configure a real SMTP provider under
**Project Settings → Authentication → SMTP Settings**. Without this, invites
silently fail to arrive once the limit is hit.

### 2. Redirect URL allow-list

Add the deep link under **Authentication → URL Configuration → Redirect URLs**:

```
propertyiq://login-callback
```

Supabase refuses to redirect anywhere not on this list.

### 3. Edge Function secret

```bash
supabase secrets set INVITE_REDIRECT_URL=propertyiq://login-callback
```

Used by both `invite-tenant` and `reset-tenant-password`. If unset, Supabase
falls back to the project's Site URL, which on a mobile-only build is unlikely
to be anything the app can handle.

### 4. Native deep-link registration

Already committed, listed here so the pieces are findable:

- `android/app/src/main/AndroidManifest.xml` — `VIEW` intent-filter for
  `propertyiq://login-callback`
- `ios/Runner/Info.plist` — `CFBundleURLTypes` with the `propertyiq` scheme

If the scheme ever changes, all four of these have to change together.

## Deploying

```bash
supabase functions deploy invite-tenant
supabase functions deploy reset-tenant-password
```

## Verifying

1. Assign a tenant to a unit using an address you control.
2. The dialog should say **Invite sent** — and show no password. A password
   appearing anywhere in this flow is a bug.
3. Open the email on a device with the app installed; the link should open the
   app on **Choose a password**, not a browser.
4. Confirm the back gesture and every other route stay blocked until a password
   is set — `resolveRedirect` pins the route while `needsPassword` is true.
5. Set a password, land on **My Unit**.
6. From the manager's unit screen, use **Send reset link** and confirm the
   tenant receives a recovery email and the manager sees only a confirmation.

## Known limitation

An invited tenant who never opens their email has an account but no usable
password. The manager can re-send with **Send reset link**. There is currently
no "invite pending / accepted" indicator in the UI to tell those apart — worth
adding if invite delivery turns out to be unreliable in practice.
