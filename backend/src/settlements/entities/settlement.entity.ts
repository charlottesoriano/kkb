import { ObjectType, Field, Int, Float } from '@nestjs/graphql';

@ObjectType()
export class Settlement {
  @Field(() => Int, { description: 'Settlement ID' })
  id: number;
  @Field(() => Int, { description: 'Group the settlement belongs to' })
  group_id: number;
  @Field(() => String, { description: 'From user ID' })
  from_user: string;
  @Field(() => String, { description: 'From user name', nullable: true })
  from_user_name: string;
  @Field(() => String, { description: 'To user ID' })
  to_user: string;
  @Field(() => String, { description: 'To user name', nullable: true })
  to_user_name: string;
  @Field(() => Float, { description: 'Settlement amount' })
  amount: number;
  @Field(() => String, { description: 'Settlement status' })
  status: string;
  @Field(() => String, { description: 'Settlement created at' })
  created_at: string;
}
