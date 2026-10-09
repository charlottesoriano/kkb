import { ForbiddenException, Inject, Injectable, NotFoundException } from '@nestjs/common';
import { CreateSettlementInput } from './dto/create-settlement.input.js';
import { UpdateSettlementInput } from './dto/update-settlement.input.js';
import { SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE } from '../supabase/supabase.provider.js';
import { RecordPaymentInput } from './dto/record-payment.input.js';
import { NotificationsService, peso } from '../notifications/notifications.service.js';
import { assertMember } from '../auth/membership.js';

const USER_COLUMNS = 'id, email, display_name, first_name, last_name, image_url, created_at';

// settlement columns with from_user and to_user expanded into users;
// the !from_user / !to_user hints pick which foreign key to join through, since both point at users
const SETTLEMENT_SELECT = `id, group_id, amount, status, created_at, from_user:users!from_user(${USER_COLUMNS}), to_user:users!to_user(${USER_COLUMNS})`;

@Injectable()
export class SettlementsService {
  constructor(
    @Inject(SUPABASE) private db: SupabaseClient,
    private notificationsService: NotificationsService,
  ) {}
  async create(createSettlementInput: CreateSettlementInput, userId: string) {
    await assertMember(this.db, createSettlementInput.group_id, userId);
    const { data, error } = await this.db
      .from('settlements')
      // every settlement starts unpaid; it moves to pending once the payer says they paid
      .insert({ ...createSettlementInput, status: 'unpaid' })
      .select(SETTLEMENT_SELECT)
      .single();
    if (error) throw error;

    return data;
  }

  // the settlement's payer and receiver; throws unless the user is one of them
  private async assertInvolved(id: number, userId: string) {
    const { data, error } = await this.db.from('settlements').select('from_user, to_user').eq('id', id).maybeSingle();
    if (error) throw error;
    if (!data) throw new NotFoundException('Settlement not found');
    if (data.from_user !== userId && data.to_user !== userId) throw new ForbiddenException('This settlement is not yours');
    return data;
  }

  async update(id: number, updateSettlementInput: UpdateSettlementInput, userId: string) {
    const settlement = await this.assertInvolved(id, userId);
    // only the receiver can say whether the money actually arrived
    if (['paid', 'rejected'].includes(updateSettlementInput.status) && settlement.to_user !== userId) {
      throw new ForbiddenException('Only the receiver can confirm or reject a payment');
    }
    // id is an identity column, so it can't be part of the update
    const { id: _id, ...changes } = updateSettlementInput;
    const { data, error } = await this.db
      .from('settlements')
      .update(changes)
      .eq('id', id)
      .select(SETTLEMENT_SELECT)
      .single();
    if (error) throw error;

    // the payer marked it as paid, so let the receiver know it's waiting for them to confirm
    if (changes.status === 'pending') await this.notifyPaymentRecorded(data);
    return data;
  }

  private async notifyPaymentRecorded(settlement: any) {
    const from = settlement.from_user;
    await this.notificationsService.create(
      from.id,
      settlement.to_user.id,
      'Payment recorded',
      `${from.display_name ?? from.email} recorded a payment of ${peso(settlement.amount)}`,
    );
  }

  async recordPayment(recordPaymentInput: RecordPaymentInput, userId: string) {
    await assertMember(this.db, recordPaymentInput.group_id, userId);
    const { data, error } = await this.db
      .from('settlements')
      // the payer says they paid; it waits as pending until the receiver confirms (paid) or rejects it,
      // so it only counts toward balances once confirmed
      .insert({ ...recordPaymentInput, status: 'pending' })
      .select(SETTLEMENT_SELECT)
      .single();
    if (error) throw error;
    await this.notifyPaymentRecorded(data);
    return data;
  }

  async remove(id: number, userId: string) {
    await this.assertInvolved(id, userId);
    const { data, error } = await this.db
      .from('settlements')
      .delete()
      .eq('id', id)
      .select(SETTLEMENT_SELECT)
      .single();
    if (error) throw error;
    return data;
  }

  async findAll(groupId: number, userId: string) {
    await assertMember(this.db, groupId, userId);
    const { data, error } = await this.db
      .from('settlements')
      .select(SETTLEMENT_SELECT)
      .eq('group_id', groupId)
      .order('created_at', { ascending: false });
    if (error) throw error;

    return data;
  }
}
