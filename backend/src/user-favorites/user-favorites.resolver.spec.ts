import { Test, TestingModule } from '@nestjs/testing';
import { UserFavoritesResolver } from './user-favorites.resolver.js';
import { UserFavoritesService } from './user-favorites.service.js';

describe('UserFavoritesResolver', () => {
  let resolver: UserFavoritesResolver;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [UserFavoritesResolver, UserFavoritesService],
    }).compile();

    resolver = module.get<UserFavoritesResolver>(UserFavoritesResolver);
  });

  it('should be defined', () => {
    expect(resolver).toBeDefined();
  });
});
