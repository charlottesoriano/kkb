import { Resolver, Query, Mutation, Args, Int } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { ClerkGuard } from '../auth/auth.guard.js';
import { CurrentUser } from '../auth/current-user.decorator.js';
import { UserFavoritesService } from './user-favorites.service.js';
import { UserFavorite } from './entities/user-favorite.entity.js';
import { CreateUserFavoriteInput } from './dto/create-user-favorite.input.js';
import { UpdateUserFavoriteInput } from './dto/update-user-favorite.input.js';

@Resolver(() => UserFavorite)
@UseGuards(ClerkGuard)
export class UserFavoritesResolver {
  constructor(private readonly userFavoritesService: UserFavoritesService) {}

  @Mutation(() => UserFavorite)
  createUserFavorite(@Args('createUserFavoriteInput') createUserFavoriteInput: CreateUserFavoriteInput, @CurrentUser() userId: string) {
    return this.userFavoritesService.create(createUserFavoriteInput, userId);
  }

  @Query(() => [UserFavorite], { name: 'userFavorites' })
  findAll(@CurrentUser() userId: string) {
    return this.userFavoritesService.findAll(userId);
  }

  @Query(() => UserFavorite, { name: 'userFavorite' })
  findOne(@Args('id', { type: () => Int }) id: number, @CurrentUser() userId: string) {
    return this.userFavoritesService.findOne(id, userId);
  }

  @Mutation(() => UserFavorite)
  updateUserFavorite(@Args('updateUserFavoriteInput') updateUserFavoriteInput: UpdateUserFavoriteInput, @CurrentUser() userId: string) {
    return this.userFavoritesService.update(updateUserFavoriteInput.id, updateUserFavoriteInput, userId);
  }

  @Mutation(() => UserFavorite)
  removeUserFavorite(@Args('id', { type: () => Int }) id: number, @CurrentUser() userId: string) {
    return this.userFavoritesService.remove(id, userId);
  }
}
