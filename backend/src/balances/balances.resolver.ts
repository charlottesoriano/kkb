import { Resolver, Query, Mutation, Args, Int, Float } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { ClerkGuard } from '../auth/auth.guard.js';
import { CurrentUser } from '../auth/current-user.decorator.js';
import { BalancesService } from './balances.service.js';
import { Balance } from './entities/balance.entity.js';
import { CreateBalanceInput } from './dto/create-balance.input.js';
import { UpdateBalanceInput } from './dto/update-balance.input.js';

@Resolver(() => Balance)
@UseGuards(ClerkGuard)
export class BalancesResolver {
  constructor(private readonly balancesService: BalancesService) {}

  @Query(() => [Balance], { name: 'groupBalances' })
  async groupBalances(@Args('groupId', { type: () => Int }) groupId: number) {
    return this.balancesService.groupBalances(groupId);
  }

  @Query(() => Float, { name: 'totalBalance' })
  async totalBalance(@CurrentUser() userId: string) {
    return this.balancesService.totalBalance(userId);
  }

  
}
