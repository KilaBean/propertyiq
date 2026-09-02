-- PropertyIQ — harden function security (Supabase advisors).
-- Applied to the remote project on 2026-06-29.

-- 1. Pin search_path on the updated_at trigger function.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- 2. Trigger-only functions: never call them via the REST API.
revoke execute on function public.set_updated_at() from public, anon, authenticated;
revoke execute on function public.handle_new_user() from public, anon, authenticated;
revoke execute on function public.link_tenancies_on_signup() from public, anon, authenticated;

-- 3. RLS helper predicates: required by policies for signed-in users only.
revoke execute on function public.owns_property(uuid) from public, anon;
grant execute on function public.owns_property(uuid) to authenticated;
revoke execute on function public.manages_unit(uuid) from public, anon;
grant execute on function public.manages_unit(uuid) to authenticated;

-- 4. create_tenancy RPC: signed-in managers only (authorisation enforced inside).
revoke execute on function
  public.create_tenancy(uuid, text, numeric, public.rent_cycle, date, date)
  from public, anon;
grant execute on function
  public.create_tenancy(uuid, text, numeric, public.rent_cycle, date, date)
  to authenticated;
