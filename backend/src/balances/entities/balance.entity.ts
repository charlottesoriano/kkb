import { ObjectType, Field, Int, Float } from '@nestjs/graphql';

@ObjectType()
export class Balance {
  @Field(() => String, { description: 'User ID' })
  user_id: string;
  @Field(() => Float, { description: 'Balance amount' })
  balance: number;
}
