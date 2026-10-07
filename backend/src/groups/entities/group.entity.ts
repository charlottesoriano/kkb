import { ObjectType, Field, Int } from '@nestjs/graphql';

@ObjectType()
export class Group {
  @Field(() => Int, { description: 'Group ID' })
  id: number;
  @Field(() => String, { description: 'Group name' })
  name: string;
  @Field(() => String, { description: 'Group description' })
  description: string;
  @Field(() => String, { description: 'Group created by' })
  created_by: string;
  @Field(() => Date, { description: 'Group created at' })
  created_at: Date;
}
