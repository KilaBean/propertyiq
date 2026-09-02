-- PropertyIQ — Phase 5b: maintenance photos
-- Adds photo_paths to requests, a private storage bucket, and storage RLS that
-- ties each object to its maintenance request (path = '<request_id>/<file>').

alter table public.maintenance_requests
  add column if not exists photo_paths text[] not null default '{}';

-- Private bucket (objects served via signed URLs).
insert into storage.buckets (id, name, public)
values ('maintenance-photos', 'maintenance-photos', false)
on conflict (id) do nothing;

-- Tenant: upload + read photos for their own requests.
drop policy if exists "mphotos_tenant_insert" on storage.objects;
create policy "mphotos_tenant_insert"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'maintenance-photos'
    and exists (
      select 1 from public.maintenance_requests mr
      where mr.id::text = (storage.foldername(name))[1]
        and mr.tenant_id = auth.uid()
    )
  );

drop policy if exists "mphotos_tenant_select" on storage.objects;
create policy "mphotos_tenant_select"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'maintenance-photos'
    and exists (
      select 1 from public.maintenance_requests mr
      where mr.id::text = (storage.foldername(name))[1]
        and mr.tenant_id = auth.uid()
    )
  );

-- Manager: read photos for requests on units they manage.
drop policy if exists "mphotos_manager_select" on storage.objects;
create policy "mphotos_manager_select"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'maintenance-photos'
    and exists (
      select 1 from public.maintenance_requests mr
      where mr.id::text = (storage.foldername(name))[1]
        and public.manages_unit(mr.unit_id)
    )
  );
