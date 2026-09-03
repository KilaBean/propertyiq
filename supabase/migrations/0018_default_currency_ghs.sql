-- PropertyIQ — default new properties to Ghana Cedi (GHS).
--
-- The app always sends `currency` explicitly on create (PropertyRepository
-- .create() takes it as a required argument), so this default is never hit
-- through the normal UI — it only matters for a row inserted some other way
-- (the SQL editor, a future admin tool). Aligning it with the client's own
-- default (property_form_screen.dart's _currencies list, GHS first) keeps
-- the two from silently disagreeing.
--
-- Existing rows are untouched: a column default only applies to rows
-- inserted after this change.
alter table public.properties
  alter column currency set default 'GHS';
