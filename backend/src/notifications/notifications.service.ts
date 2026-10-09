import { Inject, Injectable } from '@nestjs/common';
import { SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE } from '../supabase/supabase.provider.js';
import { SendReminderInput } from './dto/send-reminder.input.js';

@Injectable()
export class NotificationsService {
  constructor(
    @Inject(SUPABASE) private db: SupabaseClient
  ) {}

  async create(fromUser: string, toUser: string, title: string, description: string) {
    const { data, error } = await this.db
      .from('notifications')
      .insert({ from_user: fromUser, to_user: toUser, title, description })
      .select()
      .single();
    if (error) throw error;
    return data;
  }

  async sendReminder(fromUser: string, { group_id, to_user, amount }: SendReminderInput) {
    // the sender and group names go into the message, so the receiver knows who's asking and for which group
    const [{ data: sender, error: senderError }, { data: group, error: groupError }] = await Promise.all([
      this.db.from('users').select('first_name, display_name').eq('id', fromUser).single(),
      this.db.from('groups').select('name').eq('id', group_id).single(),
    ]);
    if (senderError) throw senderError;
    if (groupError) throw groupError;

    const amountText = amount.toLocaleString('en-PH', { style: 'currency', currency: 'PHP' });
    return this.create(
      fromUser,
      to_user,
      'Payment reminder',
      `${sender.first_name ?? sender.display_name} reminded you to pay ${amountText} in ${group.name}`,
    );
  }
}
