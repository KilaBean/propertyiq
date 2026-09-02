// PropertyIQ — trigger a password reset for a tenant (manager-only).
//
// Sends the tenant a password-recovery email. Authorization: the caller must be
// able to SEE a tenancy linking this tenant to this unit (manager RLS), which
// prevents triggering resets for arbitrary users.
//
// Like invite-tenant, this deliberately never produces a password. The earlier
// version generated one with the service role and returned it to the manager,
// which handed the manager a working credential for their tenant's account.
// The tenant now sets their own from the emailed link.
//
// Requires SMTP configured on the project. See docs/tenant-invites.md.
//
// Input:  { unitId, tenantId }
// Output: { ok, emailSent, email }

import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
const INVITE_REDIRECT_URL = Deno.env.get("INVITE_REDIRECT_URL") ?? undefined;

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(obj: unknown, status = 200): Response {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { "Content-Type": "application/json", ...CORS },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "POST only" }, 405);

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "missing authorization" }, 401);

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ error: "invalid json" }, 400);
  }

  const unitId = String(body.unitId ?? "");
  const tenantId = String(body.tenantId ?? "");
  if (!unitId || !tenantId) {
    return json({ error: "unitId and tenantId are required" }, 400);
  }

  const userClient = createClient(SUPABASE_URL, ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: userData, error: userErr } = await userClient.auth.getUser();
  if (userErr || !userData?.user) {
    return json({ error: "not authenticated" }, 401);
  }

  // Authorize: a tenancy linking this tenant to this unit must be visible to the
  // caller under RLS (i.e. they manage it). This also confirms the pairing.
  const { data: rows, error: selErr } = await userClient
    .from("tenancies")
    .select("id")
    .eq("unit_id", unitId)
    .eq("tenant_id", tenantId)
    .limit(1);
  if (selErr) return json({ error: selErr.message }, 500);
  if (!rows || rows.length === 0) {
    return json({ error: "not authorized for this tenant" }, 403);
  }

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  // Resolve the address with the service role: the manager can read the
  // tenant's profile, but not their auth.users row where the email lives.
  const { data: target, error: getErr } = await admin.auth.admin.getUserById(
    tenantId,
  );
  if (getErr || !target?.user?.email) {
    console.error("getUserById error", getErr);
    return json({ error: "tenant account not found" }, 404);
  }
  const email = target.user.email;

  // resetPasswordForEmail is on the public client, not the admin API. Using the
  // anon client keeps this on the normal recovery path (same email template and
  // rate limits as a tenant tapping "Forgot password" themselves).
  const anon = createClient(SUPABASE_URL, ANON_KEY);
  const { error: resetErr } = await anon.auth.resetPasswordForEmail(email, {
    redirectTo: INVITE_REDIRECT_URL,
  });
  if (resetErr) {
    console.error("resetPasswordForEmail error", resetErr);
    return json({ error: resetErr.message }, 400);
  }

  return json({ ok: true, emailSent: true, email }, 200);
});
