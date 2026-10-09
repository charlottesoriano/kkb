import { ObjectType, Field, Int } from '@nestjs/graphql';

@ObjectType()
export class Notification {
  @Field(() => Int, { description: 'Notification ID' })
  id: number;
  @Field(() => String, { description: 'User who triggered it' })
  from_user: string;
  @Field(() => String, { description: 'User who receives it' })
  to_user: string;
  @Field(() => String, { description: 'Notification title' })
  title: string;
  @Field(() => String, { description: 'Notification description' })
  description: string;
  @Field(() => String, { description: 'Notification created at' })
  created_at: string;
}
