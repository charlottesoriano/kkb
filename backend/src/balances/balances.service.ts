import { Inject, Injectable } from '@nestjs/common';
import { SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE } from '../supabase/supabase.provider.js';
import { User } from '../users/entities/user.entity.js';

@Injectable()
export class BalancesService {
  constructor(@Inject(SUPABASE) private db: SupabaseClient) {}

  async groupBalances(groupId: number) {
    const { data, error } = await this.db.rpc('group_balances', { p_group_id: groupId });
    if (error) throw error;
    const rows = data as { user_id: string; balance: number }[];

    const { data: users, error: usersError } = await this.db
      .from('users')
      .select('id, email, display_name, first_name, last_name, image_url, created_at')
      .in('id', rows.map((r) => r.user_id));
    if (usersError) throw usersError;

    const byId = new Map((users as User[]).map((u) => [u.id, u]));
    return rows.map((r) => ({ user: byId.get(r.user_id)!, balance: Number(r.balance) })); // [{ user: User, balance: 200 }, ...]
  }

  async totalBalance(userId: string) {
    const { data, error } = await this.db.rpc('user_total_balance', { p_user_id: userId });
    if (error) throw error;
    return data; // 200
  }

  //user's balance and money owed to them in a group
  async userGroupBalance(groupId: number, userId: string) {
    const rows = await this.groupBalances(groupId);
    return rows.find((r) => r.user.id === userId)?.balance ?? 0;
  }
}