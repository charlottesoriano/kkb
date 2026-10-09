import { SettlementsResolver } from './settlements.resolver.js';

describe('SettlementsResolver', () => {
  let service: any;
  let resolver: SettlementsResolver;

  beforeEach(() => {
    // resolvers only forward to the service, so a plain object of vi.fn()s is enough
    service = {};
    resolver = new SettlementsResolver(service);
  });

  it('should be defined', () => {
    expect(resolver).toBeDefined();
  });
});
