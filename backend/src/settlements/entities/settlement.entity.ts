import { ObjectType, Field, Int, Float } from '@nestjs/graphql';
import { User } from '../../users/entities/user.entity.js';

@ObjectType()
export class Settlement {
  @Field(() => Int, { description: 'Settlement ID' })
  id: number;
  @Field(() => Int, { description: 'Group the settlement belongs to' })
  group_id: number;
  //from user
  @Field(() => User, { description: 'From user' })
  from_user: User;
  //to user
  @Field(() => User, { description: 'To user' })
  to_user: User;
  @Field(() => Float, { description: 'Settlement amount' })
  amount: number;
  @Field(() => String, { description: 'Settlement status' })
  status: string;
  @Field(() => String, { description: 'Settlement created at' })
  created_at: string;
}
