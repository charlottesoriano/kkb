import { Inject, Injectable } from '@nestjs/common';
import { CreateUserInput } from './dto/create-user.input.js';
import { UpdateUserInput } from './dto/update-user.input.js';
import { SUPABASE } from '../supabase/supabase.provider.js';
import { SupabaseClient } from '@supabase/supabase-js';

@Injectable()
export class UsersService {
  constructor(
    @Inject(SUPABASE) private db: SupabaseClient
  ) {}

  async create(createUserInput: CreateUserInput) {
    const { data, error } = await this.db.from('users').insert(createUserInput);
    if (error) throw error;
    return 'This action adds a new user';
  }
  
  async findOne(id: String) {
    const { data, error } = await this.db.from('users').select('*').eq('id', id);
    if (error) throw error;
    return data;
  }

  async update(id: String, updateUserInput: UpdateUserInput) {
    const { data, error } = await this.db.from('users').update(updateUserInput).eq('id', id);
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
