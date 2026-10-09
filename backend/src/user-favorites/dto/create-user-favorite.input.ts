import { InputType, Int, Field } from '@nestjs/graphql';

@InputType()
export class CreateUserFavoriteInput {
  @Field(() => Int, { description: 'Group ID' })
  group_id: number;
}
