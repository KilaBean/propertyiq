# .claude/skills/ai-feature-builder/SKILL.md

---

name: propertyiq-ai-builder
description: AI workflows

AI Feature:

Maintenance Copilot

Inputs:

* Issue description
* Photos

Outputs:

* Category
* Priority
* Suggested action

Architecture:

Flutter
→ Edge Function
→ OpenAI
→ Supabase

Rules:

* Structured JSON output
* Graceful fallback
* Store results
* Low token usage

Response schema:

{
"category":"",
"priority":"",
"recommendation":""
}

Never:

* Invent repairs
* Provide legal advice
