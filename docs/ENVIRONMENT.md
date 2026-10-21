# Environment Variable Policy

This file records environment configuration principles only. Values belong in local ignored files or provider secret settings.

## Website (`website/`)
Likely browser-safe configuration (use only if actual code needs it):
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` (or existing Supabase client-safe anon key naming consistent with SDK version)
- `NEXT_PUBLIC_API_BASE_URL`
- `NEXT_PUBLIC_ANDROID_APK_URL`

Never use `NEXT_PUBLIC_` for private secrets.

## Rust backend (`backend/`)
Possible server-only names, to finalize after actual implementation:
- `PORT`
- `RUST_LOG`
- `APP_ENV`
- `CORS_ALLOWED_ORIGINS`
- `SUPABASE_URL`
- `SUPABASE_JWT_ISSUER` / JWT verification configuration appropriate to chosen library
- server-side database connection variable only if direct DB connectivity is selected
- `PAYMENT_PROVIDER_*` secret variables only after provider selection
- `WEBHOOK_*_SECRET` only if required by provider

Do not create a generic `.env` containing production values in the repository. The `.env.example` at the pack root has no secret values and is a naming template only.

## Values that must never enter source/browser bundles
- Supabase service-role/secret key
- Database password/connection URL with credentials
- Payment private keys/webhook signing secrets
- SMTP/API private keys
- Android upload keystore and passwords
- Provider admin credentials
