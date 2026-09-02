# Phase 5 — Maintenance + Gemini Copilot

Tenants file maintenance requests; a Gemini-backed Edge Function triages each
one (category + priority + recommendation); managers see triaged requests and
update status.

## Flow

```
Tenant form ─▶ MaintenanceController.submit
                  │  1. repo.triage(title, description)
                  ▼
        Edge Function `maintenance-triage` ─▶ Gemini 2.5 Flash (structured JSON)
                  │  2. repo.create(... category, priority, ai_recommendation)
                  ▼
        maintenance_requests (RLS)  ◀─ manager list/detail, status updates
```

## What shipped

| Area | Location |
|---|---|
| Migration | `supabase/migrations/0006_maintenance_requests.sql` — enums (category/priority/status), table, indexes, RLS (tenant insert/select own; manager all via `manages_unit`) |
| Edge Function | `supabase/functions/maintenance-triage/index.ts` — Gemini 2.5 Flash, `responseSchema`-constrained JSON, safe fallback, CORS, `verify_jwt` |
| Models | `lib/shared/models/` — `MaintenanceRequest` + category/priority/status enums |
| Data | `lib/features/maintenance/data/` — repository (`triage` via function, CRUD, joined views), `MaintenanceTriage`, `MaintenanceView` |
| Providers | manager/tenant lists, detail, `MaintenanceController` |
| Screens | tenant list + form + (shared) detail; manager list + (shared) detail with status control |

## AI design (per CLAUDE.md rules)

- **Key isolation:** the Gemini key lives only in the Edge Function secret
  `GEMINI_API_KEY`; the Flutter client calls the function (JWT-protected).
- **Structured output:** `responseMimeType: application/json` + a
  `responseSchema` constrain Gemini to `{category∈enum, priority∈enum,
  recommendation}`; the function re-validates enums.
- **Fallback, no fabrication:** missing key / API error / unparealsable output →
  a neutral fallback (`other`/`medium` + "team will review"), `ai_generated:false`.
  The request is always saved. The prompt explicitly forbids inventing repairs.

## ⚠️ Required to enable real AI

The function is deployed but returns the **fallback** until the secret is set:

```bash
supabase secrets set GEMINI_API_KEY=<your-google-ai-studio-key> \
  --project-ref wzixvrrjugcrzfpmprxv
```
(or Dashboard → Edge Functions → maintenance-triage → Secrets). Get a key from
Google AI Studio. No app redeploy needed — the function reads it at runtime.

## Security

- `maintenance_requests` RLS: tenant inserts/reads only their own
  (`tenant_id = auth.uid()`); manager has full access on their units' requests
  (`manages_unit(unit_id)`).
- Routes gated: `/maintenance/*` manager-only, `/my-unit/*` tenant-only.

## Tests

- `test/shared/models/maintenance_request_test.dart` — model + enum mapping,
  `in_progress` value, triage fallback parsing
- `test/core/router/maintenance_gating_test.dart` — role gating

## Validation

`flutter analyze` clean · **37 tests pass** · Android debug APK builds · DB
advisors clean (no new issues; 3 pre-existing intentional WARNs).

## Deferred

- **Photo attachments** (CLAUDE.md lists photo input). Text-only triage ships
  now; image upload (Storage) + multimodal Gemini is a follow-up.
- Manager override of AI category/priority (status updates ship now).
