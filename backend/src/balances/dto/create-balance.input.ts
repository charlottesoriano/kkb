import { InputType, Field, Float } from '@nestjs/graphql';

@InputType()
export class CreateBalanceInput {
  @Field(() => String, { description: 'User ID' })
  userId: string;
  @Field(() => String, { description: 'Expense ID' })
  expenseId: string;
  @Field(() => Float, { description: 'Balance' })
  balance: number;
}
