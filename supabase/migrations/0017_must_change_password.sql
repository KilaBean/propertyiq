-- PropertyIQ — force an invited tenant to replace the password their manager
-- generated for them.
--
-- Tenants are onboarded in person: the manager creates the account, reads the
-- generated password out, and the tenant signs in. That handover needs no email
-- infrastructure, which is why it is the shipped flow. Its weakness is not that
-- the manager sees a password once — it is that without this flag they keep a
-- working credential for their tenant's account indefinitely, with nothing
-- forcing rotation and nothing in the audit trail.
--
-- This bounds that window to "until the tenant first signs in". The router
-- pins anyone carrying the flag to /set-password and lets them nowhere else.

alter table public.profiles
  add column if not exists must_change_password boolean not null default false;

-- Set from signup metadata, so invite-tenant can raise it at account creation.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, role, phone, must_change_password)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    coalesce((new.raw_user_meta_data ->> 'role')::public.user_role, 'tenant'),
    nullif(new.raw_user_meta_data ->> 'phone', ''),
    coalesce((new.raw_user_meta_data ->> 'must_change_password')::boolean, false)
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

-- The client must not be able to clear the flag by writing the column directly,
-- so narrow its UPDATE grant to the fields a user genuinely edits. 0016 granted
-- UPDATE on the whole table; a column-level grant replaces that.
revoke update on public.profiles from authenticated;
grant update (full_name, phone, avatar_path) on public.profiles to authenticated;

-- Clearing it goes through a definer RPC instead, called once the password has
-- actually been changed via the Auth API.
create or replace function public.clear_must_change_password()
returns void
language sql
security definer
set search_path = public
as $$
  update public.profiles
  set must_change_password = false
  where id = auth.uid();
$$;

revoke execute on function public.clear_must_change_password() from public, anon;
grant execute on function public.clear_must_change_password() to authenticated;

-- Raising the flag again is a manager action (they generated a new password for
-- a tenant who lost theirs), authorised the same way as the rest of the tenancy
-- surface: the caller must manage the unit the tenant is tenanted in.
create or replace function public.require_password_change(p_tenant_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (
    select 1
    from public.tenancies t
    join public.units u on u.id = t.unit_id
    join public.properties p on p.id = u.property_id
    where t.tenant_id = p_tenant_id and p.manager_id = auth.uid()
  ) then
    raise exception 'not authorized for this tenant';
  end if;

  update public.profiles
  set must_change_password = true
  where id = p_tenant_id;
end;
$$;

revoke execute on function public.require_password_change(uuid) from public, anon;
grant execute on function public.require_password_change(uuid) to authenticated;
