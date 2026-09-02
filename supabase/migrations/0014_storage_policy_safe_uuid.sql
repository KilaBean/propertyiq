-- PropertyIQ — stop a malformed storage path from raising instead of denying.
--
-- 0011's property-photo policy casts the first path segment straight to uuid:
--     public.owns_property(((storage.foldername(name))[1])::uuid)
-- An object whose folder isn't a UUID makes that cast raise 22P02
-- (invalid_text_representation) rather than cleanly evaluating to false. A
-- policy should deny, not error.

-- Returns null instead of raising when the text isn't a UUID. `owns_property`
-- and friends return false for a null argument, so null denies.
create or replace function public.try_uuid(p text)
returns uuid
language sql
immutable
returns null on null input
as $$
  select case
    when p ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    then p::uuid
  end;
$$;

grant execute on function public.try_uuid(text) to authenticated;
revoke execute on function public.try_uuid(text) from public, anon;

drop policy if exists "pphotos_manager_all" on storage.objects;
create policy "pphotos_manager_all"
  on storage.objects for all to authenticated
  using (
    bucket_id = 'property-photos'
    and public.owns_property(public.try_uuid((storage.foldername(name))[1]))
  )
  with check (
    bucket_id = 'property-photos'
    and public.owns_property(public.try_uuid((storage.foldername(name))[1]))
  );

-- The maintenance-photo policies compare `mr.id::text = folder` (uuid rendered
-- as text, never text parsed as uuid) and the avatar policies compare
-- `folder = auth.uid()::text`, so neither can raise. They are left as-is.
