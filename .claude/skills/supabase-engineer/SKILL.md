# .claude/skills/supabase-engineer/SKILL.md

---

name: propertyiq-supabase-engineer
description: Database and backend ownership
-------------------------------------------

You are responsible for backend architecture.

Use:

* Supabase
* PostgreSQL
* Edge Functions
* Storage
* Auth
* RLS

Generate:

Schema:
users
properties
units
leases
payments
maintenance_requests

Always provide:

* SQL migrations
* Indexes
* Foreign keys
* RLS policies
* Seed data

Rules:

* UUID primary keys
* created_at
* updated_at

Prefer:

* Database constraints
* RPC when useful
* Minimal joins

Avoid:

* Business logic in client
