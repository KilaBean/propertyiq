# Phase 3 — Foundation: Theme, Routing, Supabase & Auth

This phase makes the app **runnable end-to-end for both roles**: a user can sign
up / sign in and is routed to the correct role home, backed by Supabase Auth +
an RLS-protected `profiles` table.

## What shipped

| Layer | Location | Notes |
|---|---|---|
| DB migration | `supabase/migrations/0001_profiles.sql` | `user_role` enum, `profiles` table, `updated_at` trigger, `handle_new_user` trigger, RLS |
| Env config | `lib/core/config/env.dart` | `--dart-define` only; no secrets in source |
| Supabase client | `lib/core/supabase/` + `main.dart` | `Supabase.initialize` at boot; `supabaseClientProvider` |
| Theme | `lib/core/theme/` | Light + dark, Material 3, deep-green seed, status `ThemeExtension` |
| Identity model | `lib/shared/models/` | `Profile` (Freezed) + `UserRole` enum |
| Auth | `lib/features/auth/` | repository → providers → controller → screens |
| Routing | `lib/core/router/` | GoRouter + pure `resolveRedirect` role/auth guard |
| Role homes | `dashboard/`, `tenant_home/`, `profile/`, `common/` | Phase-3 placeholders |

## Setup & run

1. **Apply the migration** (Supabase Dashboard → SQL Editor, or `supabase db push`):
   run `supabase/migrations/0001_profiles.sql`.
2. **Add the anon key** in `.vscode/launch.json` (replace `PASTE_ANON_KEY_HERE`).
   The URL is already set to the project.
3. **Run**: pick the *PropertyIQ (dev)* launch config, or:
   ```bash
   flutter run \
     --dart-define=SUPABASE_URL=https://bngupkrosrdcisghojod.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=<anon-key>
   ```
4. **Regenerate code** after editing models/providers:
   ```bash
   dart run build_runner build
   ```

## Security model

- The client **never** writes to `profiles`. The `handle_new_user` trigger
  (security definer) creates the row from signup metadata, so a user cannot set
  another user's role.
- RLS allows a user to read/update **only their own** profile. Manager→tenant
  visibility is intentionally deferred until tenancies link the two parties.

## Auth → routing flow

```
signUp/signIn ─▶ Supabase Auth ─▶ authChanges stream
                                      │
                       sessionProvider│   currentProfileProvider (role)
                                      ▼
                              resolveRedirect()  ──▶ /dashboard (manager)
                                                 └─▶ /my-unit   (tenant)
```

`resolveRedirect` is a pure function (`lib/core/router/redirect_logic.dart`) and
is unit-tested independently of the widget tree.

## Tests

- `test/core/router/redirect_logic_test.dart` — auth + role gating matrix
- `test/shared/models/profile_test.dart` — JSON mapping / defaults / round-trip
- `test/features/auth/login_screen_test.dart` — form render + validation

## AI provider (resolved for Phase 4)

> **Gemini 2.5 Flash via Google AI Studio** (`gemini-2.5-flash`) is the provider
> for **all** AI features (decision 2026-06-28; supersedes the earlier
> OpenAI/Claude options). The API key lives only in a Supabase Edge Function —
> never in the Flutter client. The Maintenance Copilot will call
> `generativelanguage.googleapis.com` `generateContent` with
> `responseMimeType: application/json` + a `responseSchema` for structured
> `{category, priority, recommendation}` output.

## Known caveats (from Phase 2, still active)

- `freezed` pinned to `3.2.6-dev.1` (only analyzer-12-compatible build).
- `riverpod_lint` / `custom_lint` deferred (analyzer constraint conflict).
- The repository keeps `data/repositories` + `presentation/{providers,screens}`
  but omits an empty `domain/usecases` layer for the auth feature — a deliberate
  anti-overengineering choice for MVP, consistent with CLAUDE.md's "avoid fancy
  architecture" guidance. Revisit if business rules grow.
