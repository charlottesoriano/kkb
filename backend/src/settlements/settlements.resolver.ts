import { Resolver, Query, Mutation, Args, Int } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { ClerkGuard } from '../auth/auth.guard.js';
import { SettlementsService } from './settlements.service.js';
import { Settlement } from './entities/settlement.entity.js';
import { CreateSettlementInput } from './dto/create-settlement.input.js';
import { UpdateSettlementInput } from './dto/update-settlement.input.js';

@Resolver(() => Settlement)
@UseGuards(ClerkGuard)
export class SettlementsResolver {
  constructor(private readonly settlementsService: SettlementsService) {}

  @Mutation(() => Settlement)
  createSettlement(@Args('createSettlementInput') createSettlementInput: CreateSettlementInput) {
    return this.settlementsService.create(createSettlementInput);
  }

  @Mutation(() => Settlement)
  updateSettlement(@Args('updateSettlementInput') updateSettlementInput: UpdateSettlementInput) {
    return this.settlementsService.update(updateSettlementInput.id, updateSettlementInput);
  }

  @Mutation(() => Settlement)
  removeSettlement(@Args('id', { type: () => Int }) id: number) {
    return this.settlementsService.remove(id);
  }
}
