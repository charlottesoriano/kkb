import { Resolver, Query, Mutation, Args, Int } from '@nestjs/graphql';
import { UserFavoritesService } from './user-favorites.service.js';
import { UserFavorite } from './entities/user-favorite.entity.js';
import { CreateUserFavoriteInput } from './dto/create-user-favorite.input.js';
import { UpdateUserFavoriteInput } from './dto/update-user-favorite.input.js';

@Resolver(() => UserFavorite)
export class UserFavoritesResolver {
  constructor(private readonly userFavoritesService: UserFavoritesService) {}

  @Mutation(() => UserFavorite)
  createUserFavorite(@Args('createUserFavoriteInput') createUserFavoriteInput: CreateUserFavoriteInput) {
    return this.userFavoritesService.create(createUserFavoriteInput);
  }

  @Query(() => [UserFavorite], { name: 'userFavorites' })
  findAll(@Args('userId', { type: () => String }) userId: string) {
    return this.userFavoritesService.findAll(userId);
  }

  @Query(() => UserFavorite, { name: 'userFavorite' })
  findOne(@Args('id', { type: () => Int }) id: number) {
    return this.userFavoritesService.findOne(id);
  }

  @Mutation(() => UserFavorite)
  updateUserFavorite(@Args('updateUserFavoriteInput') updateUserFavoriteInput: UpdateUserFavoriteInput) {
    return this.userFavoritesService.update(updateUserFavoriteInput.id, updateUserFavoriteInput);
  }

  @Mutation(() => UserFavorite)
  removeUserFavorite(@Args('id', { type: () => Int }) id: number) {
    return this.userFavoritesService.remove(id);
  }
}
