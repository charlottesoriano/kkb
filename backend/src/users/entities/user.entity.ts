import { ObjectType, Field, Int, FieldMiddleware } from '@nestjs/graphql';

// these columns can be null (Clerk user without a last name, anonymised deleted user);
// send '' instead so the non-nullable String fields don't fail the whole response
const nullToEmpty: FieldMiddleware = async (_ctx, next) => (await next()) ?? '';

@ObjectType()
export class User {
  @Field(() => String, { description: 'User ID' })
  id: string;
  @Field(() => String, { description: 'User email', middleware: [nullToEmpty] })
  email: string;
  @Field(() => String, { description: 'User display name', middleware: [nullToEmpty] })
  display_name: string;
  @Field(() => String, { description: 'User first name', middleware: [nullToEmpty] })
  first_name: string;
  @Field(() => String, { description: 'User last name', middleware: [nullToEmpty] })
  last_name: string;
  @Field(() => String, { description: 'User image URL', middleware: [nullToEmpty] })
  image_url: string;
  @Field(() => String, { description: 'User created at' })
  created_at: string;
}
