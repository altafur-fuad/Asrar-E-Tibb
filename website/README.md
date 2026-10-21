# Website (planned)

This folder is reserved for the **separate** responsive Asrar-e-Tibb website, recommended as Next.js + TypeScript, deployed to Vercel. This pack does not create a fake production website; Antigravity should scaffold it after auditing the current Flutter project and agreeing on the existing data access patterns.

Important: the existing Flutter root may already contain `web/` as a Flutter platform directory. Keep it intact. Use this `website/` directory for Next.js.

Design and product requirements: `../docs/1. PRD.md`, `../docs/2. DESIGN.md`, `../docs/3. ARCHITECTURE.md`, `../docs/11. Authentication & Security.md`. Only public-safe Supabase settings belong in browser code. Private reminders/orders/accounts must not be statically rendered or publicly cached.
