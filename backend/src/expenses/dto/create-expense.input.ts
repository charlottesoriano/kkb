import { InputType, Field, Float } from '@nestjs/graphql';

@InputType()
export class CreateExpenseInput {
  @Field() description: string;
  @Field(() => Float) amount: number;
  @Field() paidBy: string;
}
