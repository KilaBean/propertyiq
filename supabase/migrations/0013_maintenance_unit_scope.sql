-- PropertyIQ — close the maintenance insert gap.
--
-- 0006 shipped this policy:
--     with check (tenant_id = auth.uid())
-- which proves the row is filed under the caller's own id, but never checks
-- that `unit_id` is a unit the caller actually rents. Any authenticated tenant
-- who knows or guesses a unit UUID could file a request straight into an
-- unrelated manager's queue.

-- 1. Mirror of manages_unit(), from the tenant's side ---------------------------
-- `<> 'ended'` rather than `= 'active'`: a tenancy that has been set up but not
-- yet started ('pending') is still a legitimate reason to report a problem.
create or replace function public.rents_unit(p_unit_id uuid)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1 from public.tenancies t
    where t.unit_id = p_unit_id
      and t.tenant_id = auth.uid()
      and t.status <> 'ended'
  );
$$;

revoke execute on function public.rents_unit(uuid) from public, anon;
grant execute on function public.rents_unit(uuid) to authenticated;

-- 2. A tenant may only file against a unit they rent ---------------------------
drop policy if exists "maintenance_tenant_insert" on public.maintenance_requests;
create policy "maintenance_tenant_insert"
  on public.maintenance_requests for insert
  with check (
    tenant_id = auth.uid()
    and public.rents_unit(unit_id)
  );
