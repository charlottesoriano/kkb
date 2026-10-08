import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { CreateExpenseInput } from './dto/create-expense.input.js';
import { UpdateExpenseInput } from './dto/update-expense.input.js';
import { SUPABASE } from '../supabase/supabase.provider.js';
import { SupabaseClient } from '@supabase/supabase-js';

@Injectable()
export class ExpensesService {
  constructor(
    @Inject(SUPABASE) private db: SupabaseClient
  ) {}
  async create(input: CreateExpenseInput, userId: string) {
    const { data, error } = await this.db
      .from('expenses')
      .insert({
        ...input,
        paid_by: userId,
      });
    if (error) throw error;
    return data;
  }

  async findAll(groupId: string) {
    const { data, error} = await this.db
      .from('expenses')
      .select('*')
      .eq('group_id', groupId);
    if (error) throw error;
    return data;
  }

  async findOne(id: number) {
    const { data, error } = await this.db
      .from('expenses')
      .select('*')
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
      .eq('id', id);
    if (error) throw error;
    return data;
  }
}
