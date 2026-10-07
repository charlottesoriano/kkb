import { InputType, Int, Field } from '@nestjs/graphql';

@InputType()
export class CreateGroupInput {
  @Field(() => String, { description: 'Group name' })
  name: string;
  @Field(() => String, { nullable: true }) description?: string;
}
