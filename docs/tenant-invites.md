# Tenant invites & password resets

How a tenant gets an account, and why the manager's copy of their password
stops working.

## The flow

Tenants never self-register. A manager assigns a tenant to a unit, and that act
creates the account with a generated temporary password, which the manager
reads out or writes down. No email is involved.

```
Manager fills the "Assign tenant" form
        │
        ▼
invite-tenant (Edge Function)
        │  1. manages_unit()  — authorize BEFORE creating anything
        │  2. createUser(), email pre-confirmed, with a generated password
        │     and user_metadata.must_change_password = true
        │  3. create_tenancy() — link the tenancy by email
        │     └─ on failure: deleteUser() rolls back the account we created
        ▼
Manager hands over email + password
        │
        ▼
Tenant signs in
        │  profiles.must_change_password is true
        ▼
Router pins them to /set-password — nothing else is reachable
        │
        ▼
Tenant chooses their own password
        │  clear_must_change_password() → router releases them to /my-unit
        ▼
The manager's copy no longer works
```

If the address already has a PropertyIQ account, no password is generated or
returned (`invited: false`): the existing user is linked to the new tenancy and
their password is left alone. Resetting it there would lock out a tenant who is
already using the app, purely because a manager added them to a second unit.

## Why it works this way

This is a deliberate trade, revisited once and re-affirmed.

An emailed invite (`inviteUserByEmail`) would mean the manager never sees a
credential at all. It also means SMTP, a verified sending domain, deliverability
tuning, and a deep-link token exchange — the PKCE flow needs a code verifier
from the client that started the request, and an admin-generated invite has
none. That is a lot of infrastructure and one unproven mechanism, for an
onboarding conversation that happens face to face anyway.

So the generated password stays. What is **not** acceptable is the manager
keeping a working credential indefinitely, which is what the first version of
this flow did: nothing expired it and nothing forced rotation, so a manager
could sign in as their tenant months later and read their maintenance history,
with nothing in the audit trail.

`must_change_password` (migration 0017) closes that. The manager's copy works
exactly once — for the tenant's first sign-in — and dies the moment they choose
their own.

## What enforces it

| Piece | Where |
|---|---|
| Column + default | `profiles.must_change_password`, migration 0017 |
| Raised at signup | `handle_new_user()` reads it from auth metadata |
| Raised on reset | `require_password_change()`, authorised via the manager's tenancies |
| Cleared | `clear_must_change_password()`, a definer RPC |
| Client cannot forge it | `authenticated` has UPDATE only on `full_name`, `phone`, `avatar_path` — a column-level grant, so writing the flag directly is denied |
| Gate | `PasswordRecovery` provider → `resolveRedirect(needsPassword:)` → `/set-password` |

The column-level grant is the load-bearing part. Without it a tenant could
`update profiles set must_change_password = false` over the REST API and keep
using the password their manager knows.

## Resetting a lost password

**Unit detail → Reset password.** Generates a new temporary password, returns it
for the manager to hand over, and re-raises the flag so the new one is also
single-use. Authorisation is the same as everywhere else: the caller must be
able to see a tenancy linking that tenant to that unit under their own RLS.

## Deploying

```bash
supabase functions deploy invite-tenant
supabase functions deploy reset-tenant-password
```

No secrets and no SMTP are required for this flow. `GEMINI_API_KEY` is still
needed by `maintenance-triage`, which is unrelated.

## Verifying

1. Assign a tenant to a unit. The dialog shows an email and a password to share.
2. Sign in as that tenant. You should land on **Choose a password** and be
   unable to reach anything else — check the back gesture and a deep link to
   `/my-unit` both stay blocked.
3. Set a password. You should land on **My Unit**.
4. Sign out and try the *original* generated password. It must fail. If it still
   works, the flag was not raised or was cleared early — that is the bug this
   whole mechanism exists to prevent.
5. From the manager's unit screen, use **Reset password** and confirm steps 2–4
   repeat with the new one.

## If SMTP is enabled later

The pieces are already in place and mostly unused:

- `AndroidManifest.xml` and `Info.plist` register `propertyiq://login-callback`
- the `PasswordRecovery` provider already listens for
  `AuthChangeEvent.passwordRecovery`, so an emailed recovery link routes to the
  same `/set-password` screen
- `AuthRepository.resetPassword()` backs the login screen's "forgot password"

To switch invites over to email, the additions are: configure SMTP, add
`propertyiq://login-callback` to **Authentication → URL Configuration →
Redirect URLs**, set an `INVITE_REDIRECT_URL` secret, raise the auth email rate
limit, and change `invite-tenant` to call `inviteUserByEmail`. Test the token
exchange on a real device before committing to it — see the PKCE note above.

## Known limitation

There is no "invite pending / accepted" indicator. A manager cannot tell from
the UI whether a tenant ever signed in, only whether a tenancy exists. Worth
adding if handovers start going astray — `must_change_password` is exactly the
signal to surface, since it is true until the tenant's first sign-in.
