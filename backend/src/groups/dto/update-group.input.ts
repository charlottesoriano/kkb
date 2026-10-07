import { CreateGroupInput } from './create-group.input.js';
import { InputType, Field, PartialType } from '@nestjs/graphql';

@InputType()
export class UpdateGroupInput extends PartialType(CreateGroupInput) {
  // update: name, description
  @Field(() => String, { description: 'Group name' })
  name: string;
  @Field(() => String, { description: 'Group description' })
  description: string;
}
