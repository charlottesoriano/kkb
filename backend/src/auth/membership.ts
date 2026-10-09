import { ForbiddenException } from '@nestjs/common';
import { SupabaseClient } from '@supabase/supabase-js';

//throws unless the user is a member of the group, so one group's data can't be read or changed from outside it
export async function assertMember(db: SupabaseClient, groupId: number, userId: string) {
  const { data, error } = await db
    .from('members')
    .select('id')
    .eq('group_id', groupId)
    .eq('user_id', userId)
    .maybeSingle();
  if (error) throw error;
  if (!data) throw new ForbiddenException('You are not a member of this group');
}
