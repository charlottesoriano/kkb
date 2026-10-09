import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { CreateExpenseInput } from './dto/create-expense.input.js';
import { UpdateExpenseInput } from './dto/update-expense.input.js';
import { SUPABASE } from '../supabase/supabase.provider.js';
import { SupabaseClient } from '@supabase/supabase-js';
import { CreateExpenseSplitInput } from './dto/create-expense-split.input.js';

const USER_COLUMNS = 'id, email, display_name, first_name, last_name, image_url, created_at';

// expense columns with paid_by expanded into the user who paid,
// and splits expanded with the user each split belongs to
const EXPENSE_SELECT = `id, group_id, description, amount, created_at, paid_by:users!paid_by(${USER_COLUMNS}), splits:expense_splits(id, expense_id, amount, user:users!user_id(${USER_COLUMNS}))`;

@Injectable()
export class ExpensesService {
  constructor(
    @Inject(SUPABASE) private db: SupabaseClient
  ) {}
  async create(expense: CreateExpenseInput, splits: CreateExpenseSplitInput[], userId: string) {
    const { data, error } = await this.db
      .from('expenses')
      .insert({
        ...expense,
        // fall back to the current user when no payer is given
        paid_by: expense.paid_by || userId,
      })
      .select('id')
      .single();
    if (error) throw error;

    // create one expense split per user in a single insert
    if (splits.length > 0) {
      const { error: splitsError } = await this.db
        .from('expense_splits')
        .insert(splits.map(split => ({
          expense_id: data.id,
          user_id: split.user_id,
          amount: split.amount,
        })));
      if (splitsError) {
        // not a transaction, so remove the expense rather than leave it without splits
        await this.db.from('expenses').delete().eq('id', data.id);
        throw splitsError;
      }
    }

    // re-fetch so the response includes the splits just created
    return this.findOne(data.id);
  }

  async findAll(groupId: number) {
    const { data, error} = await this.db
      .from('expenses')
      .select(EXPENSE_SELECT)
      .eq('group_id', groupId)
      .order('created_at', { ascending: false });
    if (error) throw error;

    return data;
  }

  async findOne(id: number) {
    const { data, error } = await this.db
      .from('expenses')
      .select(EXPENSE_SELECT)
      .eq('id', id)
      .single();
    if (error) throw error;
    return data;
  }

  async update(id: number, updateExpenseInput: UpdateExpenseInput) {
    const { data, error } = await this.db
      .from('expenses')
      .update({
        ...updateExpenseInput,
        updated_at: new Date(),
      })
      .eq('id', id)
      .select(EXPENSE_SELECT)
      .single();
    if (error) throw error;
    return data;
  }

  async remove(id: number) {
    const { data, error } = await this.db
      .from('expenses')
      .delete()
      .eq('id', id)
      .select(EXPENSE_SELECT)
      .single();
    if (error) throw error;
    return data;
  }
}
