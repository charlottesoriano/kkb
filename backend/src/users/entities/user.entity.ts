import { ObjectType, Field, Int } from '@nestjs/graphql';

@ObjectType()
export class User {
  @Field(() => String, { description: 'User ID' })
  id: string;
  @Field(() => String, { description: 'User email' })
  email: string;
  @Field(() => String, { description: 'User display name' })
  display_name: string;
  @Field(() => String, { description: 'User first name' })
  first_name: string;
  @Field(() => String, { description: 'User last name' })
  last_name: string;
  @Field(() => String, { description: 'User image URL' })
  image_url: string;
  @Field(() => Date, { description: 'User created at' })
  created_at: Date;
}
