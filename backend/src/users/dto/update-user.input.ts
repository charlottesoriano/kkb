import { CreateUserInput } from './create-user.input.js';
import { InputType, Field, Int, PartialType } from '@nestjs/graphql';

@InputType()
export class UpdateUserInput extends PartialType(CreateUserInput) {
  @Field(() => String)
  id: string;
  //display name
  @Field(() => String, { nullable: true })
  display_name?: string;
  //first name
  @Field(() => String, { nullable: true })
  first_name?: string;
  //last name
  @Field(() => String, { nullable: true })
  last_name?: string;
}
