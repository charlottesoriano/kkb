import { Module } from '@nestjs/common';
import { ExpensesService } from './expenses.service.js';
import { ExpensesResolver } from './expenses.resolver.js';

@Module({
  providers: [ExpensesResolver, ExpensesService],
})
export class ExpensesModule {}
