import { InputType, Int, Field } from '@nestjs/graphql';

@InputType()
export class CreateUserFavoriteInput {
  @Field(() => String, { description: 'User ID' })
  user_id: string;
  @Field(() => Int, { description: 'Group ID' })
  group_id: number;
}
