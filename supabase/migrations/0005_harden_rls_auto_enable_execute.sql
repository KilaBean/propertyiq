-- PropertyIQ — harden the pre-existing `rls_auto_enable()` event-trigger
-- function. It backs the `ensure_rls` event trigger (auto-enables RLS on new
-- public tables) and is never meant to be REST-callable. Revoking EXECUTE
-- clears the advisor; the event trigger still fires regardless of grants.
-- Applied to the remote project on 2026-06-29.
revoke execute on function public.rls_auto_enable() from public, anon, authenticated;
