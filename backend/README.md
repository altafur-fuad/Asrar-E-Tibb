# Rust API Service (planned)

This folder is a **target location** for a Rust/Axum API. It is not a complete compiled service in this documentation pack. Antigravity should create it only after repository/schema audit and approval of the minimal endpoint scope.

Requirements:
- Axum/Tokio with maintained dependencies, structured sanitized logs, validation, request IDs, timeouts and graceful shutdown.
- Bind to `0.0.0.0:$PORT` for Render.
- `/healthz` and `/readyz` must be safe and not reveal env/secrets.
- Verify Supabase JWTs; derive roles server-side; do object-level authorization on every endpoint.
- Do not turn off RLS to simplify queries. Treat any service-role key as highly privileged, server-only and a potential RLS bypass.
- Dockerfile should use a multi-stage build, non-root runtime user where practical, pinned base images and minimal runtime.
- Add unit/integration tests before production.

See `../docs/3. ARCHITECTURE.md`, `../docs/5. API.md`, `../docs/11. Authentication & Security.md` and `../docs/DEPLOYMENT.md`.
