import { InputType, Field, Float, Int } from '@nestjs/graphql';

// the sender isn't here; it's the logged-in user
@InputType()
export class SendReminderInput {
  @Field(() => Int, { description: 'Group the payment belongs to' })
  group_id: number;
  @Field(() => String, { description: 'Member being reminded to pay' })
  to_user: string;
  @Field(() => Float, { description: 'Amount they still owe' })
  amount: number;
}
