import { Resolver, Query, Mutation, Args, Int } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { ClerkGuard } from '../auth/auth.guard.js';
import { UsersService } from './users.service.js';
import { User } from './entities/user.entity.js';
import { UpdateUserInput } from './dto/update-user.input.js';
import { CurrentUser } from '../auth/current-user.decorator.js';

@Resolver(() => User)
@UseGuards(ClerkGuard)
export class UsersResolver {
  constructor(private readonly usersService: UsersService) {}

  //called by the app after sign up, the user id comes from the Clerk token
  @Mutation(() => User)
  syncUser(@CurrentUser() userId: string) {
    return this.usersService.syncFromClerk(userId);
  }

  @Query(() => User, { name: 'user' })
  findOne(@CurrentUser() userId: string) {
    return this.usersService.findOne(userId);
  }

  @Mutation(() => User)
  updateUser(@CurrentUser() userId: string, @Args('updateUserInput') updateUserInput: UpdateUserInput) {
    return this.usersService.update(userId, updateUserInput);
  }

  @Mutation(() => User)
  removeUser(@CurrentUser() userId: string) {
    return this.usersService.remove(userId);
  }
}
