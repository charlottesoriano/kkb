import { ObjectType, Field, Int, Float } from '@nestjs/graphql';

@ObjectType()
export class Expense {
  @Field(() => Int) id: number;
  @Field() description: string;
  @Field(() => Float) amount: number;
  @Field() paidBy: string;
}