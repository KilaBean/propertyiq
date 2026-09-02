# PropertyIQ

Property management for small portfolios. Managers track properties, units,
tenants, leases and maintenance; tenants see their unit, file maintenance
requests, and view their rent terms.

Flutter client, Supabase backend, Gemini for maintenance triage.

## Stack

| Concern | Choice |
|---|---|
| Client | Flutter (Material 3, light + dark) |
| State | Riverpod (code-generated providers) |
| Navigation | GoRouter |
| Models | Freezed + json_serializable |
| Backend | Supabase — Postgres, Auth, Storage, Edge Functions |
| AI | Gemini 2.5 Flash, called only from an Edge Function |
| Tests | flutter_test + mocktail |

## Running it

The app reads its Supabase credentials from `--dart-define`; nothing is
hard-coded. `.vscode/launch.json` has ready-made configurations, or:

```bash
flutter run --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLISHABLE_KEY
```

`Env.assertConfigured()` fails fast in debug if either is missing, rather than
letting the Supabase SDK throw something opaque later.

The publishable (anon) key is a public client key by design — every privileged
operation is gated by row-level security, not by hiding it.

### Web

`main()` short-circuits to the marketing landing page on web. The app proper
depends on the camera and image picker, which aren't built for that target, so
there is no Supabase init and no router on the web path.

## Backend setup

Migrations are plain SQL in `supabase/migrations`, applied in filename order:

```bash
supabase db push
```

Then deploy the functions:

```bash
supabase functions deploy maintenance-triage
supabase functions deploy invite-tenant
supabase functions deploy reset-tenant-password
```

Secrets they expect:

| Secret | Used by |
|---|---|
| `GEMINI_API_KEY` | `maintenance-triage` |
| `INVITE_REDIRECT_URL` | `invite-tenant`, `reset-tenant-password` |

Tenant invites additionally need SMTP and a redirect allow-list entry — see
[docs/tenant-invites.md](docs/tenant-invites.md).

## Development

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after touching a model or provider
flutter analyze
flutter test
```

### Toolchain note

The codegen stack (freezed, riverpod_generator, build_runner) is held back by
the analyzer version, which is bounded by the Dart SDK. `pubspec.yaml` spells
the chain out. Upgrading Flutter to a Dart >= 3.13 release clears all of it at
once, including the current `freezed` pre-release pin.

## Structure

```
lib/
  app/          AppShell — the persistent bottom-nav frame
  core/         config, layout, router, theme, shared widgets, utils
  features/     one folder per feature, each data/ + presentation/
  shared/       models used across features
  dev_preview/  dev-only entrypoint for capturing marketing screenshots
supabase/
  migrations/   numbered SQL, applied in order
  functions/    Deno Edge Functions
docs/           architecture and operational notes
```

Features are two layers: `data/` (repositories talking to Supabase) and
`presentation/` (providers, screens, widgets). Presentation depends on data,
never the reverse.

## Security model

The boundary is row-level security, not the client.

- A manager reaches units, tenancies and maintenance through `manages_unit()` /
  `owns_property()`, both `security definer` so policies stay readable.
- A tenant reaches only their own rows, and since migration 0013 can only file
  maintenance against a unit they actually rent.
- Privilege escalation goes through narrow `security definer` RPCs rather than
  broad policies — `set_maintenance_photos` lets a tenant attach photos without
  an UPDATE policy that would also let them rewrite `status`.
- Trigger-only and helper functions have `EXECUTE` revoked so they aren't
  callable over REST.
- Nobody but the tenant ever knows their password. See
  [docs/tenant-invites.md](docs/tenant-invites.md).

`units.status` is derived, not stored by the client: a database trigger keeps
it in step with the unit's tenancies (migration 0012).

## Documentation

| Document | Covers |
|---|---|
| [docs/tenant-invites.md](docs/tenant-invites.md) | Invite + password recovery, and the project config it needs |
| [docs/rent-ledger-architecture.md](docs/rent-ledger-architecture.md) | Rent charges/payments design (not implemented) |
| [docs/phase-3-auth.md](docs/phase-3-auth.md) | Auth build notes |
| [docs/phase-4-properties-units.md](docs/phase-4-properties-units.md) | Properties and units |
| [docs/phase-4-tenancies.md](docs/phase-4-tenancies.md) | Tenancies |
| [docs/phase-5-maintenance.md](docs/phase-5-maintenance.md) | Maintenance and AI triage |
