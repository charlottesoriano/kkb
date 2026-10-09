import { GroupsResolver } from './groups.resolver.js';

describe('GroupsResolver', () => {
  let service: any;
  let resolver: GroupsResolver;

  beforeEach(() => {
    // resolvers only forward to the service, so a plain object of vi.fn()s is enough
    service = {};
    resolver = new GroupsResolver(service);
  });

  it('should be defined', () => {
    expect(resolver).toBeDefined();
  });
});
