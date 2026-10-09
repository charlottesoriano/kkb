import { ExpensesResolver } from './expenses.resolver.js';

describe('ExpensesResolver', () => {
  let service: any;
  let resolver: ExpensesResolver;

  beforeEach(() => {
    // resolvers only forward to the service, so a plain object of vi.fn()s is enough
    service = {};
    resolver = new ExpensesResolver(service);
  });

  it('should be defined', () => {
    expect(resolver).toBeDefined();
  });
});
