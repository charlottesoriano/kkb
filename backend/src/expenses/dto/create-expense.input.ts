import { InputType, Field, Float, Int } from '@nestjs/graphql';

@InputType()
export class CreateExpenseInput {
  @Field(() => Int, { description: 'Group the expense belongs to' })
  group_id: number;
  @Field(() => String, { description: 'Expense description' })
  description: string;
  @Field(() => Float, { description: 'Expense amount' })
  amount: number;
  @Field(() => String, { description: 'Paid by user ID' })
  paid_by: string;
}
