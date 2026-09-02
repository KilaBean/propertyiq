# Phase 4 (part 2) — Tenancies

Links a unit to a tenant with rent terms, handles tenants who haven't signed up
yet, and gives the tenant a real **My Unit** view.

## What shipped

| Area | Location |
|---|---|
| Migration | `supabase/migrations/0003_tenancies.sql` — `rent_cycle` + `tenancy_status` enums, `tenancies` table, `manages_unit()` helper, RLS, `create_tenancy()` RPC, signup-linkage trigger |
| Models | `lib/shared/models/` — `Tenancy`, `RentCycle`, `TenancyStatus` |
| Data layer | `lib/features/tenancies/` — repository, `tenanciesByUnit` + `tenantLease` providers, `TenancyController` |
| Manager UI | `unit_detail_screen.dart` (unit + tenancy section), `tenancy_form_screen.dart` (assign / edit) |
| Tenant UI | `my_unit_screen.dart` rewritten to show the active lease |

## The tenant-linkage problem & solution

A manager often invites a tenant **before** that tenant has an account, and RLS
stops the manager from reading other users' profiles. Solved with two
server-side mechanisms:

1. **`create_tenancy()` RPC** (security definer) — looks up `auth.users` by
   email and sets `tenant_id` immediately **if the tenant already exists**.
   Authorisation is enforced inside the function via `manages_unit()`, so a
   manager can only assign tenancies on units they own.
2. **`link_tenancies_on_signup()` trigger** — when a new user signs up, any
   pending tenancy whose `tenant_email` matches is linked to them.

So linkage works whether the tenant joins before or after the invite, and the
client never needs cross-user read access.

## Security (RLS)

- `tenancies`: manager has full access via `manages_unit(unit_id)`; a tenant can
  **read** rows where `tenant_id = auth.uid()`.
- Additive tenant **read** policies on `units` and `properties` let My Unit show
  the unit label + property name without exposing other managers' data.
- Business rule as a constraint: a partial unique index enforces **at most one
  active tenancy per unit**.

## Behaviour

- **Manager**: open a unit → see its tenancy; assign a tenant (email + rent +
  cycle + dates), edit, or end it. Ending frees the unit for a new active
  tenancy.
- **Tenant**: My Unit shows property, unit, rent + cycle, dates, and status, or
  a friendly empty state until a manager assigns them.
- The unit's tenancy list is a realtime stream, so manager changes appear live.

## Tests

`test/shared/models/tenancy_test.dart` — JSON mapping, enum/date parsing,
defaults, labels. (Full suite: **28 tests**.)

## Validation

`flutter analyze` clean · 28 tests pass · Android debug APK builds.

## Known limitation (future work)

Unit `status` (vacant/occupied) is still set manually and is **not** auto-derived
from the presence of an active tenancy. A future trigger could sync
`units.status` from tenancies so the occupancy KPI is always exact without
manual updates.
