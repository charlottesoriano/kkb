import { UserFavoritesResolver } from './user-favorites.resolver.js';

describe('UserFavoritesResolver', () => {
  let service: any;
  let resolver: UserFavoritesResolver;

  beforeEach(() => {
    // resolvers only forward to the service, so a plain object of vi.fn()s is enough
    service = {};
    resolver = new UserFavoritesResolver(service);
  });

  it('should be defined', () => {
    expect(resolver).toBeDefined();
  });
});
