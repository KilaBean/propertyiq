-- PropertyIQ — grant table privileges explicitly instead of inheriting them.
--
-- Postgres checks privileges FIRST and row-level security second. Every policy
-- in migrations 0001-0015 is therefore only half the story: without a table
-- GRANT, `authenticated` gets "permission denied for table ..." and the policy
-- is never consulted.
--
-- Until now nothing granted anything. The app worked only because of default
-- privileges inherited from whoever created the tables, and those differ by
-- creating role and by Supabase version. On a stack where migrations run as
-- `postgres`, the default ACL for new public tables is:
--
--   authenticated=Dxtm/postgres     (TRUNCATE, REFERENCES, TRIGGER, MAINTAIN)
--
-- which grants no SELECT, INSERT, UPDATE or DELETE at all — so a fresh project
-- provisioned from these migrations is unusable even though every policy is
-- correct. Stating the grants here makes the set portable and self-describing.
--
-- Safe to apply to an existing project: GRANT is idempotent, and this only ever
-- adds the privileges the policies already assume.

-- `anon` is deliberately absent. PropertyIQ has no anonymous surface: every
-- screen behind the router requires a session, and the landing page talks to
-- nothing. Anonymous access should fail at the privilege check, before RLS.
revoke all on public.profiles             from anon;
revoke all on public.properties           from anon;
revoke all on public.units                from anon;
revoke all on public.tenancies            from anon;
revoke all on public.maintenance_requests from anon;

-- profiles: a user reads and updates their own row (and a manager reads their
-- tenants'). Rows are created only by the handle_new_user trigger and removed
-- only by cascade from auth.users, so no INSERT or DELETE.
grant select, update on public.profiles to authenticated;

-- properties / units: a manager fully owns their own; tenants hold read-only
-- policies on the ones they are tenanted in. RLS separates the two.
grant select, insert, update, delete on public.properties to authenticated;
grant select, insert, update, delete on public.units      to authenticated;

-- tenancies: managers manage them; tenants read their own. Creation normally
-- goes through create_tenancy(), but the manager policy covers direct writes.
grant select, insert, update, delete on public.tenancies to authenticated;

-- maintenance_requests: tenants insert and read their own; managers do
-- everything on requests for units they manage.
grant select, insert, update, delete on public.maintenance_requests
  to authenticated;

-- service_role bypasses RLS and is used only by Edge Functions holding the
-- service key. Granting explicitly keeps it from depending on defaults too.
grant all on public.profiles             to service_role;
grant all on public.properties           to service_role;
grant all on public.units                to service_role;
grant all on public.tenancies            to service_role;
grant all on public.maintenance_requests to service_role;
