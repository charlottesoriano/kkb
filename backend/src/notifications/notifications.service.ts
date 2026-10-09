import { Inject, Injectable, Logger } from '@nestjs/common';
import { SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE } from '../supabase/supabase.provider.js';
import { SendReminderInput } from './dto/send-reminder.input.js';
import { Messaging } from 'firebase-admin/messaging';
import { FIREBASE_MESSAGING } from './firebase.provider.js';
import { assertMember } from '../auth/membership.js';

// 1234.5 -> ₱1,234.50
export const peso = (amount: number) => Number(amount).toLocaleString('en-PH', { style: 'currency', currency: 'PHP' });

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);
  constructor(
    @Inject(SUPABASE) private db: SupabaseClient,
    @Inject(FIREBASE_MESSAGING) private messaging: Messaging
  ) {}

  async create(fromUser: string, toUser: string, title: string, description: string) {
    const { data, error } = await this.db
      .from('notifications')
      .insert({ from_user: fromUser, to_user: toUser, title, description })
      .select()
      .single();
    if (error) throw error;
    await this.push(toUser, title, description);
    return data;
  }

  //get user's notifications
  async getUserNotifications(userId: string) {
    const { data, error } = await this.db
      .from('notifications')
      .select(`
        *,
        from_user: users!notifications_from_user_fkey (
          id,
          display_name,
          first_name,
          last_name
        ),
        to_user: users!notifications_to_user_fkey (
          id,
          display_name,
          first_name,
          last_name
        )
      `)
      .eq('to_user', userId)
      .order('created_at', { ascending: false });
    if (error) throw error;
    return data;
  }

  async sendReminder(fromUser: string, { group_id, to_user, amount }: SendReminderInput) {
    // both people have to be in the group, so reminders can't be sent to strangers
    await assertMember(this.db, group_id, fromUser);
    await assertMember(this.db, group_id, to_user);

    // the sender and group names go into the message, so the receiver knows who's asking and for which group
    const [{ data: sender, error: senderError }, { data: group, error: groupError }] = await Promise.all([
      this.db.from('users').select('first_name, display_name').eq('id', fromUser).single(),
      this.db.from('groups').select('name').eq('id', group_id).single(),
    ]);
    if (senderError) throw senderError;
    if (groupError) throw groupError;

    // create() saves the notification and pushes it to the receiver's devices
    return this.create(
      fromUser,
      to_user,
      'Payment reminder',
      `${sender.first_name ?? sender.display_name} reminded you to pay ${peso(amount)} in ${group.name}`,
    );
  }

  async registerDeviceToken(userId: string, token: string) {
    // a device belongs to whoever signed in last, so the previous account stops getting pushes on it
    const { error: claimError } = await this.db.from('device_tokens').delete().eq('token', token).neq('user_id', userId);
    if (claimError) throw claimError;

    const { error } = await this.db
      .from('device_tokens')
      .upsert({ user_id: userId, token, updated_at: new Date().toISOString() }, { onConflict: 'user_id,token' });
    if (error) throw error;
    return true;
  }

  // called on sign out, so the device stops getting this user's notifications
  async unregisterDeviceToken(userId: string, token: string) {
    const { error } = await this.db.from('device_tokens').delete().eq('user_id', userId).eq('token', token);
    if (error) throw error;
    return true;
  }

  private async push(userId: string, title: string, body: string) {
    try {
      const { data: rows, error } = await this.db.from('device_tokens').select('token').eq('user_id', userId);
      if (error) throw error;
      if (!rows.length) return;

      const tokens = rows.map((row) => row.token);
      const result = await this.messaging.sendEachForMulticast({ tokens, notification: { title, body } });

      // FCM rejects tokens from uninstalled apps or expired installs; drop them so they aren't retried
      const dead = tokens.filter((_, i) => {
        const code = result.responses[i].error?.code;
        return code === 'messaging/registration-token-not-registered' || code === 'messaging/invalid-registration-token';
      });
      if (dead.length) await this.db.from('device_tokens').delete().in('token', dead);
    } catch (e) {
      this.logger.warn(`Push to ${userId} failed: ${e}`);
    }
  }
}
{}
