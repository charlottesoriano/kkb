import { Resolver, Query, Mutation, Args, Int } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { ClerkGuard } from '../auth/auth.guard.js';
import { CurrentUser } from '../auth/current-user.decorator.js';
import { GroupsService } from './groups.service.js';
import { Group } from './entities/group.entity.js';
import { CreateGroupInput } from './dto/create-group.input.js';
import { UpdateGroupInput } from './dto/update-group.input.js';
import { User } from '../users/entities/user.entity.js';

@Resolver(() => Group)
@UseGuards(ClerkGuard)
export class GroupsResolver {
  constructor(private readonly groupsService: GroupsService) {}

  @Mutation(() => Group)
  createGroup(@Args('input') input: CreateGroupInput, @CurrentUser() userId: string) {
    return this.groupsService.create(input, userId);
  }

  @Mutation(() => Group)
  updateGroup(@Args('input') input: UpdateGroupInput, @Args('groupId', { type: () => Int }) groupId: number, @CurrentUser() userId: string) {
    return this.groupsService.update(groupId, input, userId);
  }

  @Mutation(() => Group)
  removeGroup(@Args('groupId', { type: () => Int }) groupId: number, @CurrentUser() userId: string) {
    return this.groupsService.remove(groupId, userId);
  }

  @Query(() => [Group], { name: 'userGroups' })
  async userGroups(@CurrentUser() userId: string) {
    return this.groupsService.findUserGroups(userId);
  }

  @Query(() => [Group], { name: 'favoriteGroups' })
  async favoriteGroups(@CurrentUser() userId: string) {
    return this.groupsService.findFavoriteGroups(userId);
  }

  @Query(() => [User], { name: 'groupMembers' })
  async groupMembers(@Args('groupId', { type: () => Int }) groupId: number, @CurrentUser() userId: string) {
    return this.groupsService.findGroupMembers(groupId, userId);
  }

  @Mutation(() => Boolean)
  removeMemberFromGroup(
    @Args('groupId', { type: () => Int }) groupId: number,
    @Args('userId', { type: () => String }) userId: string,
    @CurrentUser() currentUserId: string,
  ) {
    return this.groupsService.removeMember(groupId, userId, currentUserId);
  }

  @Mutation(() => Group)
  async addMemberToGroup(@Args('groupCode', { type: () => String }) groupCode: string, @CurrentUser() userId: string) {
    return this.groupsService.addGroupMember(groupCode, userId);
  }

  @Mutation(() => Boolean, { description: 'Toggles the group in the user favorites, returns the new favorite status' })
  async favoriteGroup(@Args('groupId', { type: () => Int }) groupId: number, @CurrentUser() userId: string) {
    return this.groupsService.favoriteGroup(groupId, userId);
  }
}
