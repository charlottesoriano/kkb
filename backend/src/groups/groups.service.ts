import { Inject, Injectable } from '@nestjs/common';
import { CreateGroupInput } from './dto/create-group.input.js';
import { UpdateGroupInput } from './dto/update-group.input.js';
import { SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE } from '../supabase/supabase.provider.js';

@Injectable()
export class GroupsService {
  constructor(
    @Inject(SUPABASE) private db: SupabaseClient
  ) {}

  async create(createGroupInput: CreateGroupInput, userId: string) {
    const { data, error } = await this.db
      .from('groups')
      .insert({
        ...createGroupInput,
        created_by: userId,
      });
    if (error) throw error;
    return data;
  }

  async findUserGroups(userId: string) {
    const { data, error } = await this.db
      .from('groups')
      .select('*, members!inner(user_id, users!inner(id, email, display_name, first_name, last_name, image_url))')
      .eq('members.users.id', userId);
    if (error) throw error;
    return data;
  }

  async findGroupMembers(groupId: number) {
    const { data, error } = await this.db
      .from('members')
      .select('*, users!inner(id, email, display_name, first_name, last_name, image_url)')
      .eq('group_id', groupId);
    if (error) throw error;
    return data;
  }

  async update(groupId: number, updateGroupInput: UpdateGroupInput) {
    const { data, error } = await this.db
      .from('groups')
      .update(updateGroupInput)
      .eq('id', groupId);
    if (error) throw error;
    return data;
  }

  async remove(groupId: number) {
    const { data, error } = await this.db
      .from('groups')
      .delete()
      .eq('id', groupId);
    if (error) throw error;
    return data;
  }

  async removeMember(groupId: number, userId: string) {
    const { data, error } = await this.db
      .from('members')
      .delete()
      .eq('group_id', groupId)
      .eq('user_id', userId);
    if (error) throw error;
    return data;
  }
}
