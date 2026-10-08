import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { CreateExpenseInput } from './dto/create-expense.input.js';
import { UpdateExpenseInput } from './dto/update-expense.input.js';
import { SUPABASE } from '../supabase/supabase.provider.js';
import { SupabaseClient } from '@supabase/supabase-js';

// expense columns with paid_by expanded into the user who paid
const EXPENSE_SELECT = 'id, group_id, description, amount, created_at, paid_by:users!paid_by(id, email, display_name, first_name, last_name, image_url, created_at)';

@Injectable()
export class ExpensesService {
  constructor(
    @Inject(SUPABASE) private db: SupabaseClient
  ) {}
  async create(expense: CreateExpenseInput, userId: string) {
    const { data, error } = await this.db
      .from('expenses')
      .insert({
        ...expense,
        // fall back to the current user when no payer is given
        paid_by: expense.paid_by || userId,
      })
      .select(EXPENSE_SELECT)
      .single();
    if (error) throw error;
    return data;
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
      .eq('id', id);
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
