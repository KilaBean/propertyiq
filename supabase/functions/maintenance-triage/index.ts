// PropertyIQ — Maintenance Copilot triage (Gemini 2.5 Flash).
// Input:  { title: string, description: string }
// Output: { category, priority, recommendation, ai_generated }
//
// The Gemini key lives ONLY here (Edge Function secret GEMINI_API_KEY), never
// in the client. On any failure or missing key we return a safe fallback so the
// tenant's request still goes through. We never fabricate specific repairs.

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY");
const MODEL = "gemini-2.5-flash";

const CATEGORIES = [
  "plumbing", "electrical", "structural", "hvac", "appliance", "pest", "other",
];
const PRIORITIES = ["low", "medium", "high", "urgent"];

const FALLBACK = {
  category: "other",
  priority: "medium",
  recommendation:
    "Our maintenance team will review your request and follow up shortly.",
  ai_generated: false,
};

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

  let body: { title?: unknown; description?: unknown };
  try {
    body = await req.json();
  } catch {
    return json({ error: "invalid json" }, 400);
  }

  const title = String(body.title ?? "").slice(0, 200);
  const description = String(body.description ?? "").slice(0, 2000);
  if (!title && !description) {
    return json({ error: "title or description required" }, 400);
  }

  if (!GEMINI_API_KEY) return json(FALLBACK, 200);

  try {
    const prompt =
      "You are a property maintenance triage assistant. Classify the tenant's " +
      "maintenance request into a category and priority, and give brief, safe " +
      "next-step guidance for the manager. Do not invent repairs or promise " +
      "specific fixes.\n\n" +
      `Title: ${title}\nDescription: ${description}`;

    const res = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${GEMINI_API_KEY}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{ role: "user", parts: [{ text: prompt }] }],
          generationConfig: {
            temperature: 0.2,
            responseMimeType: "application/json",
            responseSchema: {
              type: "OBJECT",
              properties: {
                category: { type: "STRING", enum: CATEGORIES },
                priority: { type: "STRING", enum: PRIORITIES },
                recommendation: { type: "STRING" },
              },
              required: ["category", "priority", "recommendation"],
            },
          },
        }),
      },
    );

    if (!res.ok) {
      console.error("gemini error", res.status, await res.text());
      return json(FALLBACK, 200);
    }

    const data = await res.json();
    const text = data?.candidates?.[0]?.content?.parts?.[0]?.text;
    if (!text) return json(FALLBACK, 200);

    const parsed = JSON.parse(text);
    const category = CATEGORIES.includes(parsed.category)
      ? parsed.category
      : "other";
    const priority = PRIORITIES.includes(parsed.priority)
      ? parsed.priority
      : "medium";
    const recommendation = String(parsed.recommendation ?? FALLBACK.recommendation)
      .slice(0, 1000);

    return json({ category, priority, recommendation, ai_generated: true }, 200);
  } catch (e) {
    console.error("triage exception", e);
    return json(FALLBACK, 200);
  }
});
