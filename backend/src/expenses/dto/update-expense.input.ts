import { CreateExpenseInput } from './create-expense.input.js';
import { InputType, Field, Int, PartialType, Float } from '@nestjs/graphql';

@InputType()
export class UpdateExpenseInput extends PartialType(CreateExpenseInput) {
  @Field(() => Int, { description: 'Expense ID' })
  id: number;
  // update: description, amount, paid_by
  @Field(() => String, { description: 'Expense description' })
  description: string;
  @Field(() => Float, { description: 'Expense amount' })
  amount: number;
  @Field(() => String, { description: 'Paid by user ID' })
  paid_by: string;
}
