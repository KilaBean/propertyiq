# Phase 4 (part 1) — Properties → Units → Dashboard

A complete, runnable manager slice: model properties and their units, with live
KPIs on the dashboard. **Tenancies are part 2** (separate, because linking a
tenant — a different user — needs its own migration, RLS, and signup-linkage).

## What shipped

| Area | Location |
|---|---|
| Migration | `supabase/migrations/0002_properties_units.sql` — `unit_status` enum, `properties` + `units` tables, FKs, indexes, `updated_at` triggers, RLS (+ `owns_property()` helper) |
| Models | `lib/shared/models/` — `Property`, `Unit`, `UnitStatus` (Freezed) |
| Properties feature | `lib/features/properties/` — repository, list/detail/controller providers, list + form + detail screens |
| Units feature | `lib/features/units/` — repository, units-by-property provider, controller, form screen |
| Dashboard | `lib/features/dashboard/` — `DashboardStats` + provider, KPI metric cards |
| Shared widgets | `lib/core/widgets/` — `AsyncValueView`, `EmptyState`, `MetricCard`, `PropertyCard`, `UnitCard`; `lib/core/utils/formatters.dart` |

## Behaviour

- **Manager dashboard** shows Properties / Units / Occupied / Occupancy% with
  pull-to-refresh, and a button into property management.
- **Properties**: list (live), create, edit, delete (cascades to units).
- **Units**: listed inside a property (live), create, edit, delete; status
  vacant/occupied drives a colored chip and the occupancy KPI.
- All lists use Supabase **realtime streams**, so adds/edits appear without a
  manual refresh; the dashboard recomputes on change.

## Security

- `properties`: a manager has full access only to rows where
  `manager_id = auth.uid()`.
- `units`: access is derived from owning the parent property via the
  `owns_property()` security-definer helper — no unit is reachable without
  owning its property.
- The client never sets `manager_id`; it comes from the session.
- Routing also gates all `/properties/*` routes to managers (defence in depth on
  top of RLS).

## Tests

- `test/shared/models/property_unit_test.dart` — JSON mapping / defaults / round-trip
- `test/features/dashboard/dashboard_stats_test.dart` — occupancy math / empty
- `test/core/router/properties_gating_test.dart` — manager-only route gating

## Validation

`flutter analyze` clean · **25 tests pass** · Android debug APK builds.

## Next (Phase 4 part 2)

Tenancies: `tenancies` table (hub linking unit ↔ tenant with rent/cycle/dates),
invite-by-email + signup linkage so a manager can attach a tenant who hasn't
joined yet, RLS giving the tenant read access to their own tenancy, and the
tenant **My Unit** screen showing real lease data.
