import { Inject, Injectable } from '@nestjs/common';
import { CreateSettlementInput } from './dto/create-settlement.input.js';
import { UpdateSettlementInput } from './dto/update-settlement.input.js';
import { SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE } from '../supabase/supabase.provider.js';

const SETTLEMENT_SELECT = 'id, group_id, from_user, to_user, amount, status, created_at';

@Injectable()
export class SettlementsService {
  constructor(
    @Inject(SUPABASE) private db: SupabaseClient
  ) {}
  async create(createSettlementInput: CreateSettlementInput) {
    const { data, error } = await this.db
      .from('settlements')
      .insert(createSettlementInput)
      .select(SETTLEMENT_SELECT)
      .single();
    if (error) throw error;
    return data;
  }

  async update(id: number, updateSettlementInput: UpdateSettlementInput) {
    const { data, error } = await this.db
      .from('settlements')
      .update(updateSettlementInput)
      .eq('id', id);
    if (error) throw error;
    return data;
  }

  async remove(id: number) {
    const { data, error } = await this.db
      .from('settlements')
      .delete()
      .eq('id', id)
      .select(SETTLEMENT_SELECT)
      .single();
    if (error) throw error;
    return data;
  }
}
