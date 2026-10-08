import { InputType, Field, Float, Int } from '@nestjs/graphql';

@InputType()
export class CreateSettlementInput {
  @Field(() => Int, { description: 'Group the settlement belongs to' })
  group_id: number;
  @Field(() => String, { description: 'From user ID' })
  from_user: string;
  @Field(() => String, { description: 'To user ID' })
  to_user: string;
  @Field(() => Float, { description: 'Settlement amount' })
  amount: number;
}
