-- PropertyIQ — put the streamed tables on the realtime publication.
--
-- Three repositories subscribe with `.stream(primaryKey: ['id'])`:
--   * PropertyRepository.watchByManager  -> properties, filtered by manager_id
--   * UnitRepository.watchByProperty     -> units,      filtered by property_id
--   * TenancyRepository.watchByUnit      -> tenancies,  filtered by unit_id
-- Until now no migration added any of them to `supabase_realtime`, so whether
-- those lists actually live-update depended on someone having ticked the box in
-- the dashboard. Declaring it here makes it reproducible on a fresh project.

do $$
begin
  if not exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    create publication supabase_realtime;
  end if;
end$$;

do $$
declare
  v_table text;
begin
  foreach v_table in array array['properties', 'units', 'tenancies'] loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public'
        and tablename = v_table
    ) then
      execute format(
        'alter publication supabase_realtime add table public.%I', v_table);
    end if;
  end loop;
end$$;

-- Realtime evaluates the client's `.eq(...)` filter and RLS against the WAL
-- record. The default replica identity only carries the primary key, so a
-- DELETE would arrive with no manager_id / property_id / unit_id to match on
-- and would be dropped instead of removing the row from the client's list.
alter table public.properties replica identity full;
alter table public.units      replica identity full;
alter table public.tenancies  replica identity full;
