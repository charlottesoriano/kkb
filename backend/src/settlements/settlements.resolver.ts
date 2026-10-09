import { Resolver, Query, Mutation, Args, Int } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { ClerkGuard } from '../auth/auth.guard.js';
import { CurrentUser } from '../auth/current-user.decorator.js';
import { SettlementsService } from './settlements.service.js';
import { Settlement } from './entities/settlement.entity.js';
import { CreateSettlementInput } from './dto/create-settlement.input.js';
import { UpdateSettlementInput } from './dto/update-settlement.input.js';
import { RecordPaymentInput } from './dto/record-payment.input.js';

@Resolver(() => Settlement)
@UseGuards(ClerkGuard)
export class SettlementsResolver {
  constructor(private readonly settlementsService: SettlementsService) {}

  @Mutation(() => Settlement)
  createSettlement(@Args('createSettlementInput') createSettlementInput: CreateSettlementInput, @CurrentUser() userId: string) {
    return this.settlementsService.create(createSettlementInput, userId);
  }

  @Mutation(() => Settlement)
  updateSettlement(@Args('updateSettlementInput') updateSettlementInput: UpdateSettlementInput, @CurrentUser() userId: string) {
    return this.settlementsService.update(updateSettlementInput.id, updateSettlementInput, userId);
  }

  @Mutation(() => Settlement)
  recordPayment(@Args('recordPaymentInput') recordPaymentInput: RecordPaymentInput, @CurrentUser() userId: string) {
    return this.settlementsService.recordPayment(recordPaymentInput, userId);
  }

  @Mutation(() => Settlement)
  removeSettlement(@Args('id', { type: () => Int }) id: number, @CurrentUser() userId: string) {
    return this.settlementsService.remove(id, userId);
  }

  @Query(() => [Settlement], { name: 'settlements' })
  findAll(@Args('groupId', { type: () => Int }) groupId: number, @CurrentUser() userId: string) {
    return this.settlementsService.findAll(groupId, userId);
  }
}
