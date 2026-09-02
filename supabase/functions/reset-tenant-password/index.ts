// PropertyIQ — reset a tenant's password (manager-only).
// Generates a new temporary password for a tenant on a unit the caller manages,
// and returns it for the manager to share. Authorization: the caller must be
// able to SEE a tenancy linking this tenant to this unit (manager RLS), which
// prevents resetting arbitrary users' passwords.
//
// Input:  { unitId, tenantId }
// Output: { ok, password }

import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;

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

function generatePassword(len = 12): string {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789";
  const buf = new Uint32Array(len);
  crypto.getRandomValues(buf);
  let out = "";
  for (let i = 0; i < len; i++) out += chars[buf[i] % chars.length];
  return out;
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

  // Reset the password with the service role.
  const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);
  const password = generatePassword();
  const { error: updErr } = await admin.auth.admin.updateUserById(tenantId, {
    password,
  });
  if (updErr) {
    console.error("updateUserById error", updErr);
    return json({ error: updErr.message }, 400);
  }

  return json({ ok: true, password }, 200);
});
