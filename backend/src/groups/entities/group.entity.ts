import { ObjectType, Field, Int } from '@nestjs/graphql';
import { User } from '../../users/entities/user.entity.js';

@ObjectType()
export class Group {
  @Field(() => Int, { description: 'Group ID' })
  id: number;
  @Field(() => String, { description: 'Group code' })
  code: string;
  @Field(() => String, { description: 'Group name' })
  name: string;
  @Field(() => String, { description: 'Group description' })
  description: string;
  @Field(() => String, { description: 'Group created by' })
  created_by: string;
  @Field(() => String, { description: 'Group created at' })
  created_at: string;
  @Field(() => Boolean, { nullable: true, description: 'Whether the current user favorited this group' })
  is_favorite?: boolean;
  @Field(() => [User], { nullable: true, description: 'Group members' })
  members?: User[];
  @Field(() => String, { defaultValue: '#984063', description: 'Group avatar color' })
  avatar_color: string;
}
