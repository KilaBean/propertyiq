// PropertyIQ — invite a tenant (manager-only).
//
// Creates the tenant's auth account with a generated temporary password (email
// pre-confirmed so they can sign in immediately) and returns it for the manager
// to hand over. Then creates the tenancy. Tenants never self-register; only a
// manager who owns the unit can invite, enforced via manages_unit() before any
// account is created.
//
// Why a generated password rather than an emailed invite: tenants are onboarded
// in person, and this path needs no SMTP, no verified sending domain, and no
// deep-link token exchange. See docs/tenant-invites.md.
//
// The account is created with must_change_password, so the password below stops
// working the moment the tenant first signs in and chooses their own. That is
// what keeps the manager from holding a working credential indefinitely — do
// not remove it without reading the note in that document.
//
// Input:  { unitId, email, fullName?, phone?, rentAmount?, rentCycle?,
//           startDate?, endDate?, utilityAmount?, depositAmount?,
//           emergencyContact? }
// Output: { ok, invited, email, password }
//         password is null when the address already had an account (we cannot
//         read an existing one, and must not reset it behind the tenant's back)

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

// Readable temp password: no ambiguous glyphs, because this gets read aloud or
// written on paper. crypto.getRandomValues, not Math.random.
function generatePassword(len = 12): string {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789";
  const buf = new Uint32Array(len);
  crypto.getRandomValues(buf);
  let out = "";
  for (let i = 0; i < len; i++) out += chars[buf[i] % chars.length];
  return out;
}

const EMAIL_RE = /^[^@\s]+@[^@\s.]+\.[^@\s]+$/;

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
  const email = String(body.email ?? "").trim().toLowerCase();
  const fullName = String(body.fullName ?? "");
  const phone = String(body.phone ?? "");
  if (!unitId || !email) {
    return json({ error: "unitId and email are required" }, 400);
  }
  if (!EMAIL_RE.test(email)) {
    return json({ error: "that doesn't look like an email address" }, 400);
  }

  // Caller context — authorize against the manager's own RLS/RPC.
  const userClient = createClient(SUPABASE_URL, ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: userData, error: userErr } = await userClient.auth.getUser();
  if (userErr || !userData?.user) {
    return json({ error: "not authenticated" }, 401);
  }

  // Authorize BEFORE creating any account.
  const { data: manages, error: mErr } = await userClient.rpc("manages_unit", {
    p_unit_id: unitId,
  });
  if (mErr) return json({ error: mErr.message }, 500);
  if (manages !== true) {
    return json({ error: "not authorized for this unit" }, 403);
  }

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);
  const password = generatePassword();
  let invited = false;
  let returnedPassword: string | null = null;
  // Only set when THIS request created the account, so the rollback below can
  // never delete a pre-existing user.
  let createdUserId: string | null = null;

  const { data: created, error: createErr } = await admin.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: {
      role: "tenant",
      full_name: fullName,
      phone,
      // Read by handle_new_user (migration 0017). Without this the generated
      // password would keep working for as long as the tenant never changed it.
      must_change_password: true,
    },
  });

  if (createErr) {
    const msg = (createErr.message ?? "").toLowerCase();
    const alreadyExists = msg.includes("already") ||
      msg.includes("registered") || msg.includes("exists");
    if (!alreadyExists) {
      console.error("createUser error", createErr);
      return json({ error: createErr.message }, 400);
    }
    // Already has an account — link them to the tenancy and leave their
    // password alone. Resetting it here would lock out a tenant who is already
    // using the app, purely because a manager added them to a second unit.
  } else {
    invited = true;
    returnedPassword = password;
    createdUserId = created?.user?.id ?? null;
  }

  // Create the tenancy as the manager (re-checks manages_unit, links by email).
  const { error: tErr } = await userClient.rpc("create_tenancy", {
    p_unit_id: unitId,
    p_tenant_email: email,
    p_rent_amount: body.rentAmount ?? 0,
    p_rent_cycle: body.rentCycle ?? "monthly",
    p_start_date: body.startDate ?? null,
    p_end_date: body.endDate ?? null,
    p_utility_amount: body.utilityAmount ?? 0,
    p_deposit_amount: body.depositAmount ?? 0,
    p_emergency_contact: body.emergencyContact ?? null,
  });

  if (tErr) {
    console.error("create_tenancy error", tErr);
    // Roll back the account this request created. Without this the address
    // reads as "already registered" on every retry, so the tenant would never
    // get a password and the manager could never complete the assignment.
    if (createdUserId) {
      const { error: rollbackErr } = await admin.auth.admin.deleteUser(
        createdUserId,
      );
      if (rollbackErr) {
        console.error("rollback deleteUser failed", createdUserId, rollbackErr);
      }
    }
    return json({ error: tErr.message }, 400);
  }

  return json({ ok: true, invited, email, password: returnedPassword }, 200);
});
