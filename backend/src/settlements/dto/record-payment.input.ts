//id, group, from_user, to_user, amount, status
import { InputType, Field, Float, Int } from '@nestjs/graphql';

@InputType()
export class RecordPaymentInput {
  @Field(() => Int, { description: 'Group the payment belongs to' })
  group_id: number;
  @Field(() => String, { description: 'From user ID' })
  from_user: string;
  @Field(() => String, { description: 'To user ID' })
  to_user: string;
  @Field(() => Float, { description: 'Payment amount' })
  amount: number;
}