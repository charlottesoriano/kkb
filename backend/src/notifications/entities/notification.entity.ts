import { ObjectType, Field, Int } from '@nestjs/graphql';
import { User } from '../../users/entities/user.entity.js';

@ObjectType()
export class Notification {
  @Field(() => Int, { description: 'Notification ID' })
  id: number;
  //from user 
  @Field(() => User, { description: 'User who triggered it' })
  from_user: User;
  //to user
  @Field(() => User, { description: 'User who receives it' })
  to_user: User;
  @Field(() => String, { description: 'Notification title' })
  title: string;
  @Field(() => String, { description: 'Notification description' })
  description: string;
  @Field(() => String, { description: 'Notification created at' })
  created_at: string;
}
