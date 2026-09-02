-- PropertyIQ — harden the pre-existing `rls_auto_enable()` event-trigger
-- function. It backs the `ensure_rls` event trigger (auto-enables RLS on new
-- public tables) and is never meant to be REST-callable. Revoking EXECUTE
-- clears the advisor; the event trigger still fires regardless of grants.
-- Applied to the remote project on 2026-06-29.
--
-- Guarded, because the function is not created by any migration: it was added
-- directly to the remote project, so it does not exist on a fresh database.
-- Revoking unconditionally made the whole migration set unreproducible — a new
-- project, a staging environment or CI would fail here at `supabase db reset`
-- and never reach 0006 onwards.
do $$
begin
  if exists (
    select 1
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'rls_auto_enable'
  ) then
    revoke execute on function public.rls_auto_enable()
      from public, anon, authenticated;
  end if;
end$$;
