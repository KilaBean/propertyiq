// PropertyIQ — invite a tenant (manager-only).
//
// Sends the tenant a Supabase invite email and creates the tenancy. Tenants
// never self-register; only a manager who owns the unit can invite, enforced
// via manages_unit() before any account is created.
//
// This function deliberately never produces a password. The earlier version
// generated a temporary one and returned it for the manager to pass along,
// which meant the manager permanently held a working credential for their
// tenant's account — enough to sign in as them and read their maintenance
// history, with nothing in the audit trail. The tenant now sets their own
// password from the emailed link and is the only party who ever knows it.
//
// Requires: SMTP configured on the project (the built-in sender is rate
// limited and not suitable for production) and INVITE_REDIRECT_URL pointing at
// a deep link the app handles. See docs/tenant-invites.md.
//
// Input:  { unitId, email, fullName?, phone?, rentAmount?, rentCycle?,
//           startDate?, endDate?, utilityAmount?, depositAmount?,
//           emergencyContact? }
// Output: { ok, invited, email }
//         invited=true  -> an invite email was sent to a new account
//         invited=false -> the address already had an account; it was linked to
//                          the tenancy and no email was sent

import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
// Where the emailed invite link lands. Unset in local dev falls back to the
// project's Site URL, configured in the Supabase dashboard.
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

// Deliberately permissive — the address only has to be deliverable, and the
// invite email failing is a better signal than a regex arguing with the user.
const EMAIL_RE = /^[^@\s]+@[^@\s.]+\.[^@\s]+$/;

function isAlreadyRegistered(message: string | undefined): boolean {
  const m = (message ?? "").toLowerCase();
  return m.includes("already") || m.includes("registered") || m.includes("exists");
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

  // Admin context — send the invite. The tenant sets their own password from
  // the emailed link; nothing here ever sees it.
  const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  let invited = false;
  // Only set when THIS request created the account, so rollback below can never
  // delete a pre-existing user.
  let createdUserId: string | null = null;

  const { data: inviteData, error: inviteErr } = await admin.auth.admin
    .inviteUserByEmail(email, {
      data: { role: "tenant", full_name: fullName, phone },
      redirectTo: INVITE_REDIRECT_URL,
    });

  if (inviteErr) {
    if (!isAlreadyRegistered(inviteErr.message)) {
      console.error("inviteUserByEmail error", inviteErr);
      return json({ error: inviteErr.message }, 400);
    }
    // Already has an account — link them to the tenancy without emailing.
    // create_tenancy resolves the existing auth user by email.
  } else {
    invited = true;
    createdUserId = inviteData?.user?.id ?? null;
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
    // Roll back the account this request created, otherwise a failed tenancy
    // leaves an orphaned auth user: the address is now "already registered",
    // so every retry takes the branch above and the tenant never gets an
    // invite email.
    if (createdUserId) {
      const { error: rollbackErr } = await admin.auth.admin.deleteUser(
        createdUserId,
      );
      if (rollbackErr) {
        // Surfaced for operator cleanup — the tenancy failed either way.
        console.error("rollback deleteUser failed", createdUserId, rollbackErr);
      }
    }
    return json({ error: tErr.message }, 400);
  }

  return json({ ok: true, invited, email }, 200);
});
