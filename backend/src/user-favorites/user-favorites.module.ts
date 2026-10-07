import { Module } from '@nestjs/common';
import { UserFavoritesService } from './user-favorites.service.js';
import { UserFavoritesResolver } from './user-favorites.resolver.js';

@Module({
  providers: [UserFavoritesResolver, UserFavoritesService],
})
export class UserFavoritesModule {}
