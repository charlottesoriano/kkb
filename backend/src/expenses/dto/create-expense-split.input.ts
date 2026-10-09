//user_id and amount
import { InputType, Field, Float, Int } from '@nestjs/graphql';

@InputType()
export class CreateExpenseSplitInput {
  @Field(() => String, { description: 'User ID' })
  user_id: string;
  @Field(() => Float, { description: 'Amount' })
  amount: number;
}