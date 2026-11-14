import { createClient } from '@supabase/supabase-js'

const supabaseOptions = {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
}

// Service role client — bypasses RLS, stateless (never mutates session)
export const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY,
  supabaseOptions
)

// Isolated client factory for signInWithPassword so it never overwrites the service_role Authorization header
export const createAuthClient = () =>
  createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_KEY,
    supabaseOptions
  )