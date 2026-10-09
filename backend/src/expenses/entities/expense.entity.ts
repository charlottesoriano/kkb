import { ObjectType, Field, Int, Float } from '@nestjs/graphql';
import { User } from '../../users/entities/user.entity.js';
import { ExpenseSplit } from './expense_split.entity.js';

@ObjectType()
export class Expense {
  @Field(() => Int, { description: 'Expense ID' })
  id: number;
  @Field(() => Int, { description: 'Group the expense belongs to' })
  group_id: number;
  @Field(() => String, { description: 'Expense description' })
  description: string;
  @Field(() => Float, { description: 'Expense amount' })
  amount: number;
  @Field(() => User, { description: 'User who paid the expense' })
  paid_by: User;
  @Field(() => String, { description: 'Expense created at' })
  created_at: string;
  @Field(() => [ExpenseSplit], { description: 'Expense splits' })
  splits: ExpenseSplit[];
}
