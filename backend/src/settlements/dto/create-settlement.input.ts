import { InputType, Field, Float } from '@nestjs/graphql';

@InputType()
export class CreateSettlementInput {
  @Field(() => String, { description: 'From user ID' })
  from_user: string;
  @Field(() => String, { description: 'To user ID' })
  to_user: string;
  @Field(() => Float, { description: 'Settlement amount' })
  amount: number;
}
