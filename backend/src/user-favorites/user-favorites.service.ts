import { Inject, Injectable } from '@nestjs/common';
import { CreateUserFavoriteInput } from './dto/create-user-favorite.input.js';
import { UpdateUserFavoriteInput } from './dto/update-user-favorite.input.js';
import { SUPABASE } from '../supabase/supabase.provider.js';
import { SupabaseClient } from '@supabase/supabase-js';

@Injectable()
export class UserFavoritesService {
  constructor(
    @Inject(SUPABASE) private db: SupabaseClient
  ) {}
  async create(createUserFavoriteInput: CreateUserFavoriteInput, userId: string) {
    const { data, error } = await this.db
      .from('user_favorites')
      .insert({ ...createUserFavoriteInput, user_id: userId })
      .select()
      .single();
    if (error) throw error;
    return data;
  }

  async findAll(userId: string) {
    const { data, error } = await this.db
      .from('user_favorites')
      .select('*')
      .eq('user_id', userId);
    if (error) throw error;
    return data;
  }

  async findOne(id: number, userId: string) {
    const { data, error } = await this.db
      .from('user_favorites')
      .select('*')
      .eq('id', id)
      .eq('user_id', userId)
      .single();
    if (error) throw error;
    return data;
  }

  async update(id: number, updateUserFavoriteInput: UpdateUserFavoriteInput, userId: string) {
    const { data, error } = await this.db
      .from('user_favorites')
      .update(updateUserFavoriteInput)
      .eq('id', id)
      .eq('user_id', userId)
      .select()
      .single();
    if (error) throw error;
    return data;
  }

  async remove(id: number, userId: string) {
    const { data, error } = await this.db
      .from('user_favorites')
      .delete()
      .eq('id', id)
      .eq('user_id', userId)
      .select()
      .single();
    if (error) throw error;
    return data;
  }
}
