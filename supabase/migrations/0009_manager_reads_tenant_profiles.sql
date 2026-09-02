-- PropertyIQ — let a manager read the profile (name, phone) of a tenant who is
-- tenanted in one of their units. Needed to show tenant names on requests and
-- the Tenant Profile screen.

drop policy if exists "profiles_manager_select_tenants" on public.profiles;
create policy "profiles_manager_select_tenants"
  on public.profiles for select
  using (
    exists (
      select 1
      from public.tenancies t
      join public.units u on u.id = t.unit_id
      join public.properties p on p.id = u.property_id
      where t.tenant_id = profiles.id and p.manager_id = auth.uid()
    )
  );
