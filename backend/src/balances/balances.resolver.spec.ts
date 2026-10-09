import { BalancesResolver } from './balances.resolver.js';

describe('BalancesResolver', () => {
  let service: any;
  let resolver: BalancesResolver;

  beforeEach(() => {
    // resolvers only forward to the service, so a plain object of vi.fn()s is enough
    service = {};
    resolver = new BalancesResolver(service);
  });

  it('should be defined', () => {
    expect(resolver).toBeDefined();
  });
});
