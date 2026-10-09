import { UsersResolver } from './users.resolver.js';

describe('UsersResolver', () => {
  let service: any;
  let resolver: UsersResolver;

  beforeEach(() => {
    // resolvers only forward to the service, so a plain object of vi.fn()s is enough
    service = {};
    resolver = new UsersResolver(service);
  });

  it('should be defined', () => {
    expect(resolver).toBeDefined();
  });
});
