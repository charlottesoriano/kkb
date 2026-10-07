import { Module } from '@nestjs/common';
import { BalancesService } from './balances.service.js';
import { BalancesResolver } from './balances.resolver.js';

@Module({
  providers: [BalancesResolver, BalancesService],
})
export class BalancesModule {}
