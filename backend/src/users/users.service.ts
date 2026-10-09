import { Inject, Injectable } from '@nestjs/common';
import { createClerkClient } from '@clerk/backend';
import { UpdateUserInput } from './dto/update-user.input.js';
import { SUPABASE } from '../supabase/supabase.provider.js';
import { SupabaseClient } from '@supabase/supabase-js';

@Injectable()
export class UsersService {
  private clerk = createClerkClient({ secretKey: process.env.CLERK_SECRET_KEY });

  constructor(
    @Inject(SUPABASE) private db: SupabaseClient
  ) {}

  //creates the users row for a Clerk user right after sign up, so the app doesn't have to wait for the user.created webhook
  //an existing row is left as is, so a display name changed in settings is never overwritten
  async syncFromClerk(id: string) {
    const u = await this.clerk.users.getUser(id);
    const { error } = await this.db.from('users').upsert(
      {
        id: u.id,
        email: u.primaryEmailAddress?.emailAddress ?? u.emailAddresses[0]?.emailAddress,
        display_name: [u.firstName, u.lastName].filter(Boolean).join(' ') || u.username,
        first_name: u.firstName,
        last_name: u.lastName,
        image_url: u.imageUrl,
      },
      { onConflict: 'id', ignoreDuplicates: true },
    );
    if (error) throw error;
    return this.findOne(id);
  }
  
  async findOne(id: String) {
    const { data, error } = await this.db.from('users').select('*').eq('id', id).single();
    if (error) throw error;
    return data;
  }

  async update(id: String, updateUserInput: UpdateUserInput) {
    //id comes from the signed-in user, so never write the input's id column
    const { id: _, ...fields } = updateUserInput;
    const { data, error } = await this.db.from('users').update(fields).eq('id', id).select().single();
    if (error) throw error;
    return data;
  }

  async remove(id: String) {
    //just update the deleted_at to the current date time
    const { data, error } = await this.db.from('users').update({ deleted_at: new Date().toISOString() }).eq('id', id).select().single();
    if (error) throw error;
    return data;
  }
}
