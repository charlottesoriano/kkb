import { BadRequestException, Inject, Injectable, NotFoundException } from '@nestjs/common';
import { CreateGroupInput } from './dto/create-group.input.js';
import { UpdateGroupInput } from './dto/update-group.input.js';
import { SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE } from '../supabase/supabase.provider.js';
import { randomInt } from 'crypto';
import { createClerkClient } from '@clerk/backend';
import { User } from '../users/entities/user.entity.js';

const CODE_ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

@Injectable()
export class GroupsService {
  constructor(
    @Inject(SUPABASE) private db: SupabaseClient
  ) {}

  generateGroupCode(): string {
    // 8 chars from A-Z and 2-9, skipping look-alikes (0/O, 1/I)
    let code = '';
    for (let i = 0; i < 8; i++) {
      code += CODE_ALPHABET[randomInt(CODE_ALPHABET.length)];
    }
    return code;
  }  

  //returns a list of groups
  async getGroupMembersByGroupId(groupId: number): Promise<User[]> {
    const { data: members, error } = await this.db
      .from('members')
      .select('*, users!inner(id, email, display_name, first_name, last_name, image_url, created_at)')
      .eq('group_id', groupId);
    if (error) throw error;
    return members.map((member) => member.users as User);
  }


  async create(input: CreateGroupInput, userId: string) {
    let code = this.generateGroupCode();
    for (let attempt = 0; attempt < 5; attempt++) {
      const { data: existing, error } = await this.db.from('groups').select('id').eq('code', code);
      if (error) throw error;
      if (!existing.length) break;
      code = this.generateGroupCode();
    }

    const { data, error } = await this.db
      .from('groups')
      .insert({
        name: input.name,
        description: input.description,
        avatar_color: input.avatarColor,
        created_by: userId,
        code: code,
      })
      .select()
      .single();

    if (error) throw error;

    //automatically add the user to the group
    await this.addGroupMember(code, userId);
    return data;
  }

  async findUserGroups(userId: string) {
    //only groups the user is a member of
    const { data: memberships, error: membershipsError } = await this.db
      .from('members')
      .select('group_id')
      .eq('user_id', userId);
    if (membershipsError) throw membershipsError;
    const groupIds = memberships.map((membership) => membership.group_id);
    if (!groupIds.length) return [];

    //the user_favorites filter only narrows the embedded rows (used for is_favorite), not the groups
    const { data, error } = await this.db
      .from('groups')
      .select(`
          *,
          user_favorites(user_id)
        `)
      .in('id', groupIds)
      .eq('user_favorites.user_id', userId);


    if (error) throw error;

    return Promise.all(data.map(async (group) => {
      //get group members
      let members:User[] = await this.getGroupMembersByGroupId(group.id);
      return {
        ...group,
        created_at: new Date(group.created_at),
        is_favorite: group.user_favorites.length > 0,
        members: members,
      };
    }));
  }

  async findFavoriteGroups(userId: string) {
    //!inner turns the embeds into filters: only groups the user favorited AND is still a member of
    const { data, error } = await this.db
      .from('groups')
      .select(`
          *,
          user_favorites!inner(user_id),
          membership:members!inner(user_id)
        `)
      .eq('user_favorites.user_id', userId)
      .eq('membership.user_id', userId);

    if (error) throw error;

    return Promise.all(data.map(async ({ user_favorites, membership, ...group }) => {
      let members:User[] = await this.getGroupMembersByGroupId(group.id);
      return {
        ...group,
        created_at: new Date(group.created_at),
        is_favorite: true,
        members: members,
      };
    }));
  }

  async findGroupMembers(groupId: number) {
    const { data, error } = await this.db
      .from('members')
      .select('*, users!inner(id, email, display_name, first_name, last_name, image_url)')
      .eq('group_id', groupId);
    if (error) throw error;
    return data;
  }

  async update(groupId: number, input: UpdateGroupInput) {
    const { data, error } = await this.db
      .from('groups')
      .update(input)
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

  async addGroupMember(groupCode: string, userId: string) {
    const { data: group, error: groupError } = await this.db
      .from('groups')
      .select('*')
      .eq('code', groupCode)
      .maybeSingle();
    if (groupError) throw groupError;
    if (!group) throw new NotFoundException('Group not found');
  
    const { data: member, error: memberError } = await this.db
      .from('members')
      .select('id')
      .eq('group_id', group.id)
      .eq('user_id', userId)
      .maybeSingle();
    if (memberError) throw memberError;
    if (member) throw new BadRequestException('User is already a member of the group');

    await this.ensureUserExists(userId);

    const { data: newMember, error: newMemberError } = await this.db
      .from('members')
      .insert({ group_id: group.id, user_id: userId })
      .select()
      .single();
    if (newMemberError) throw newMemberError;
    //return the new group data with the new member
    const groupMembers = await this.getGroupMembersByGroupId(group.id);
    return {
      ...group,
      created_at: new Date(group.created_at),
      members: groupMembers,
    };
  }

  //users rows normally come from the Clerk webhook; if it never arrived
  //(backend offline at sign-up, db reset), copy the user from Clerk now so members_user_id_fkey holds
  private async ensureUserExists(userId: string) {
    const { data: existing, error } = await this.db
      .from('users')
      .select('id')
      .eq('id', userId)
      .maybeSingle();
    if (error) throw error;
    if (existing) return;

    const clerk = createClerkClient({ secretKey: process.env.CLERK_SECRET_KEY });
    const u = await clerk.users.getUser(userId);
    const { error: upsertError } = await this.db.from('users').upsert(
      {
        id: u.id,
        email: u.primaryEmailAddress?.emailAddress ?? u.emailAddresses[0]?.emailAddress ?? null,
        display_name: [u.firstName, u.lastName].filter(Boolean).join(' ') || u.username,
        first_name: u.firstName,
        last_name: u.lastName,
        image_url: u.imageUrl,
        deleted_at: null,
      },
      { onConflict: 'id' },
    );
    if (upsertError) throw upsertError;
  }

  async favoriteGroup(groupId: number, userId: string) {
    //if the group is already in the user's favorites, remove it, otherwise add it
    const { data, error } = await this.db
      .from('user_favorites')
      .select('id')
      .eq('group_id', groupId)
      .eq('user_id', userId)
      .maybeSingle();
    if (error) throw error;
    if (data) {
      const { error: deleteError } = await this.db
        .from('user_favorites')
        .delete()
        .eq('id', data.id);
      if (deleteError) throw deleteError;
    } else {
      const { error: insertError } = await this.db
        .from('user_favorites')
        .insert({ group_id: groupId, user_id: userId });
      if (insertError) throw insertError;
    }
    //the new favorite status
    return !data;
  }
}
