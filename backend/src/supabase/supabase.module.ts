import { Global, Module } from '@nestjs/common';
import { supabaseProvider, SUPABASE } from './supabase.provider.js';

@Global() // Make the module global so it can be imported in other modules
@Module({
  providers: [supabaseProvider],
  exports: [SUPABASE],
})
export class SupabaseModule {}
