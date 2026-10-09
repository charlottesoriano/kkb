import { ObjectType, Field, Int, Float } from '@nestjs/graphql';
import { User } from '../../users/entities/user.entity.js';

@ObjectType()
export class ExpenseSplit {
  //id, expense_id, user, amount
  @Field(() => Int, { description: 'Expense split ID' })
  id: number;
  @Field(() => Int, { description: 'Expense ID' })
  expense_id: number;
  @Field(() => User, { description: 'User who split the expense' })
  user: User;
  @Field(() => Float, { description: 'Amount of the expense split' })
  amount: number;
}
