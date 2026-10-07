import { CreateUserFavoriteInput } from './create-user-favorite.input.js';
import { InputType, Field, Int, PartialType } from '@nestjs/graphql';

@InputType()
export class UpdateUserFavoriteInput extends PartialType(CreateUserFavoriteInput) {
  @Field(() => Int)
  id: number;
}
