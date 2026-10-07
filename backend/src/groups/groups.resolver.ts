import { Resolver, Query, Mutation, Args, Int } from '@nestjs/graphql';
import { GroupsService } from './groups.service.js';
import { Group } from './entities/group.entity.js';
import { CreateGroupInput } from './dto/create-group.input.js';
import { UpdateGroupInput } from './dto/update-group.input.js';

@Resolver(() => Group)
export class GroupsResolver {
  constructor(private readonly groupsService: GroupsService) {}

  @Mutation(() => Group)
  createGroup(@Args('createGroupInput') createGroupInput: CreateGroupInput, @Args('userId', { type: () => String }) userId: string) {
    return this.groupsService.create(createGroupInput, userId);
  }

  @Mutation(() => Group)
  updateGroup(@Args('updateGroupInput') updateGroupInput: UpdateGroupInput, @Args('groupId', { type: () => Int }) groupId: number) {
    return this.groupsService.update(groupId, updateGroupInput);
  }

  @Mutation(() => Group)
  removeGroup(@Args('groupId', { type: () => Int }) groupId: number) {
    return this.groupsService.remove(groupId);
  }

  @Query(() => [Group], { name: 'userGroups' })
  async userGroups(@Args('userId', { type: () => String }) userId: string) {
    return this.groupsService.findUserGroups(userId);
  }

  @Query(() => [String], { name: 'groupMembers' })
  async groupMembers(@Args('groupId', { type: () => Int }) groupId: number) {
    return this.groupsService.findGroupMembers(groupId);
  }

  @Mutation(() => String)
  removeMemberFromGroup(@Args('groupId', { type: () => Int }) groupId: number, @Args('userId', { type: () => String }) userId: string) {
    return this.groupsService.removeMember(groupId, userId);
  }
}
