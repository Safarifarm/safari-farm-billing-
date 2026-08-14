import { createClient } from '@supabase/supabase-js'
const url = import.meta.env.VITE_SUPABASE_URL || 'https://eplhgmetrhaixuzcpwdb.supabase.co'
const key = import.meta.env.VITE_SUPABASE_ANON_KEY || 'sb_publishable_t3sr4pLmvm6-aCv6Eq6vmg_xujs4HFm'
export const hasSupabase = Boolean(url && key && !url.includes('YOUR_PROJECT'))
export const supabase = hasSupabase ? createClient(url, key) : null
