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
  findAll(@Args('groupId', { type: () => Int }) groupId: number) {
    return this.expensesService.findAll(groupId);
  }

  @Query(() => Expense, { name: 'expense' })
  findOne(@Args('id', { type: () => Int }) id: number) {
    return this.expensesService.findOne(id);
  }

  @Mutation(() => Expense)
  updateExpense(@Args('updateExpenseInput') updateExpenseInput: UpdateExpenseInput) {
    return this.expensesService.update(updateExpenseInput.id, updateExpenseInput);
  }

  @Mutation(() => Expense)
  removeExpense(@Args('id', { type: () => Int }) id: number) {
    return this.expensesService.remove(id);
  }
}
