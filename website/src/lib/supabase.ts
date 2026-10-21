/**
 * Asrar-e-Tibb: Client-Safe Public Supabase Configuration
 * Only public client keys are read. Never contains service-role secrets.
 */

export const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
export const SUPABASE_ANON_KEY = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';

export function isSupabaseConfigured(): boolean {
  return Boolean(SUPABASE_URL && SUPABASE_ANON_KEY);
}

/**
 * Lightweight browser fetch helper for Supabase PostgREST
 */
export async function supabaseRestQuery(table: string, queryParams: string = ''): Promise<any> {
  if (!isSupabaseConfigured()) {
    console.warn('Supabase is not configured via environment variables. Operating in local dataset fallback mode.');
    return { data: null, error: 'SUPABASE_NOT_CONFIGURED' };
  }

  const endpoint = `${SUPABASE_URL}/rest/v1/${table}${queryParams ? `?${queryParams}` : ''}`;
  try {
    const res = await fetch(endpoint, {
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json'
      }
    });

    if (!res.ok) {
      return { data: null, error: `HTTP ${res.status}: ${await res.text()}` };
    }

    const data = await res.json();
    return { data, error: null };
  } catch (err: any) {
    return { data: null, error: err.message };
  }
}
