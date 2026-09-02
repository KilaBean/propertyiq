-- PropertyIQ — let a tenant attach photo paths to their OWN request without a
-- broad UPDATE policy (which would also let them change status/category).
-- A definer RPC updates only photo_paths after verifying ownership.

create or replace function public.set_maintenance_photos(p_id uuid, p_paths text[])
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.maintenance_requests
  set photo_paths = coalesce(p_paths, '{}')
  where id = p_id and tenant_id = auth.uid();
end;
$$;

revoke execute on function public.set_maintenance_photos(uuid, text[])
  from public, anon;
grant execute on function public.set_maintenance_photos(uuid, text[])
  to authenticated;
