import { Inject, Injectable } from '@nestjs/common';
import { CreateSettlementInput } from './dto/create-settlement.input.js';
import { UpdateSettlementInput } from './dto/update-settlement.input.js';
import { SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE } from '../supabase/supabase.provider.js';
import { RecordPaymentInput } from './dto/record-payment.input.js';

const USER_COLUMNS = 'id, email, display_name, first_name, last_name, image_url, created_at';

// settlement columns with from_user and to_user expanded into users;
// the !from_user / !to_user hints pick which foreign key to join through, since both point at users
const SETTLEMENT_SELECT = `id, group_id, amount, status, created_at, from_user:users!from_user(${USER_COLUMNS}), to_user:users!to_user(${USER_COLUMNS})`;

@Injectable()
export class SettlementsService {
  constructor(
    @Inject(SUPABASE) private db: SupabaseClient
  ) {}
  async create(createSettlementInput: CreateSettlementInput) {
    const { data, error } = await this.db
      .from('settlements')
      // every settlement starts unpaid; it moves to pending once the payer says they paid
      .insert({ ...createSettlementInput, status: 'unpaid' })
      .select(SETTLEMENT_SELECT)
      .single();
    if (error) throw error;

    return data;
  }

  async update(id: number, updateSettlementInput: UpdateSettlementInput) {
    // id is an identity column, so it can't be part of the update
    const { id: _id, ...changes } = updateSettlementInput;
    const { data, error } = await this.db
      .from('settlements')
      .update(changes)
      .eq('id', id)
      .select(SETTLEMENT_SELECT)
      .single();
    if (error) throw error;
    return data;
  }

  async recordPayment(recordPaymentInput: RecordPaymentInput) {
    const { data, error } = await this.db
      .from('settlements')
      // the payer says they paid; it waits as pending until the receiver confirms (paid) or rejects it,
      // so it only counts toward balances once confirmed
      .insert({ ...recordPaymentInput, status: 'pending' })
      .select(SETTLEMENT_SELECT)
      .single();
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

  async findAll(groupId: number) {
    const { data, error } = await this.db
      .from('settlements')
      .select(SETTLEMENT_SELECT)
      .eq('group_id', groupId)
      .order('created_at', { ascending: false });
    if (error) throw error;

    return data;
  }
}
