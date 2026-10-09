import { Resolver, Query, Mutation, Args, Int } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { ClerkGuard } from '../auth/auth.guard.js';
import { CurrentUser } from '../auth/current-user.decorator.js';
import { ExpensesService } from './expenses.service.js';
import { Expense } from './entities/expense.entity.js';
import { CreateExpenseInput } from './dto/create-expense.input.js';
import { UpdateExpenseInput } from './dto/update-expense.input.js';
import { CreateExpenseSplitInput } from './dto/create-expense-split.input.js';

@Resolver(() => Expense)
@UseGuards(ClerkGuard)
export class ExpensesResolver {
  constructor(private readonly expensesService: ExpensesService) {}

  @Mutation(() => Expense)
  createExpense(
    @Args('createExpenseInput') createExpenseInput: CreateExpenseInput,
    @Args('splits', { type: () => [CreateExpenseSplitInput] }) splits: CreateExpenseSplitInput[],
    @CurrentUser() userId: string,
  ) {
    // scenario for the user id: the user may have been asked to create an expense paid by another member
    return this.expensesService.create(createExpenseInput, splits, userId);
  }

  @Query(() => [Expense], { name: 'expenses' })
  findAll(@Args('groupId', { type: () => Int }) groupId: number, @CurrentUser() userId: string) {
    return this.expensesService.findAll(groupId, userId);
  }

  @Query(() => Expense, { name: 'expense' })
  async findOne(@Args('id', { type: () => Int }) id: number, @CurrentUser() userId: string) {
    await this.expensesService.assertCanAccess(id, userId);
    return this.expensesService.findOne(id);
  }

  @Mutation(() => Expense)
  updateExpense(@Args('updateExpenseInput') updateExpenseInput: UpdateExpenseInput, @CurrentUser() userId: string) {
    return this.expensesService.update(updateExpenseInput.id, updateExpenseInput, userId);
  }

  @Mutation(() => Expense)
  removeExpense(@Args('id', { type: () => Int }) id: number, @CurrentUser() userId: string) {
    return this.expensesService.remove(id, userId);
  }
}
