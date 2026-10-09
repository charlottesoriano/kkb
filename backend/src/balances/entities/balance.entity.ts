import { ObjectType, Field, Int, Float } from '@nestjs/graphql';
import { User } from '../../users/entities/user.entity.js';

@ObjectType()
export class Balance {
  @Field(() => User, { description: 'User' })
  user: User;
  @Field(() => Float, { description: 'Balance amount' })
  balance: number;
}
