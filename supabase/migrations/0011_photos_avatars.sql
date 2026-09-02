-- PropertyIQ — property cover photos + user avatars.
-- New columns, two private Storage buckets, and RLS scoped by folder = owner.

alter table public.properties add column if not exists photo_path text;
alter table public.profiles add column if not exists avatar_path text;

insert into storage.buckets (id, name, public)
values ('property-photos', 'property-photos', false)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', false)
on conflict (id) do nothing;

-- property-photos: path = '<property_id>/<file>'. Manager owns the property.
drop policy if exists "pphotos_manager_all" on storage.objects;
create policy "pphotos_manager_all"
  on storage.objects for all to authenticated
  using (
    bucket_id = 'property-photos'
    and public.owns_property(((storage.foldername(name))[1])::uuid)
  )
  with check (
    bucket_id = 'property-photos'
    and public.owns_property(((storage.foldername(name))[1])::uuid)
  );

-- avatars: path = '<user_id>/<file>'. Anyone manages their own avatar.
drop policy if exists "avatars_owner_all" on storage.objects;
create policy "avatars_owner_all"
  on storage.objects for all to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- avatars: a manager can also view the avatar of a tenant tenanted in one of
-- their units (mirrors profiles_manager_select_tenants).
drop policy if exists "avatars_manager_select_tenants" on storage.objects;
create policy "avatars_manager_select_tenants"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'avatars'
    and exists (
      select 1
      from public.tenancies t
      join public.units u on u.id = t.unit_id
      join public.properties p on p.id = u.property_id
      where t.tenant_id::text = (storage.foldername(name))[1]
        and p.manager_id = auth.uid()
    )
  );
