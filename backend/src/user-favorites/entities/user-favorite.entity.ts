import { ObjectType, Field, Int } from '@nestjs/graphql';

@ObjectType()
export class UserFavorite {
  @Field(() => String, { description: 'User ID' })
  user_id: string;
  @Field(() => Int, { description: 'Group ID' })
  group_id: number;
  @Field(() => String, { description: 'Created at' })
  created_at: string;
}
