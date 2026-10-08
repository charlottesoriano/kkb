import { Inject, Injectable } from '@nestjs/common';
import { SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE } from '../supabase/supabase.provider.js';

@Injectable()
export class BalancesService {
  constructor(@Inject(SUPABASE) private db: SupabaseClient) {}

  async groupBalances(groupId: number) {
    const { data, error } = await this.db.rpc('group_balances', { p_group_id: groupId });
    if (error) throw error;
    return data; // [{ user_id: 'user_AAA', balance: 200 }, ...]
  }

  async totalBalance(userId: string) {
    const { data, error } = await this.db.rpc('user_total_balance', { p_user_id: userId });
    if (error) throw error;
    return data; // 200
  }

  //user's balance and money owed to them in a group
  async userGroupBalance(groupId: number, userId: string) {
    const rows = await this.groupBalances(groupId);
    return rows.find((r: { user_id: string; balance: number }) => r.user_id === userId)?.balance ?? 0;
  }
}