import { createClient } from '@supabase/supabase-js';

export const SUPABASE = 'SUPABASE';

export const supabaseProvider = {
  provide: SUPABASE,
  useFactory: () =>
    createClient(process.env.SUPABASE_URL || '', process.env.SUPABASE_SERVICE_KEY || ''),
};