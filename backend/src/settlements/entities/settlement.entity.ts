import { ObjectType, Field, Int, Float } from '@nestjs/graphql';

@ObjectType()
export class Settlement {
  @Field(() => String, { description: 'From user ID' })
  from_user: string;
  @Field(() => String, { description: 'From user name' })
  from_user_name: string;
  @Field(() => String, { description: 'To user ID' })
  to_user: string;
  @Field(() => String, { description: 'To user name' })
  to_user_name: string;
  @Field(() => Float, { description: 'Settlement amount' })
  amount: number;
  @Field(() => String, { description: 'Settlement status' })
  status: string;
  @Field(() => String, { description: 'Settlement created at' })
  created_at: string;
}
