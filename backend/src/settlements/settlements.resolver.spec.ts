import { Test, TestingModule } from '@nestjs/testing';
import { SettlementsResolver } from './settlements.resolver.js';
import { SettlementsService } from './settlements.service.js';

describe('SettlementsResolver', () => {
  let resolver: SettlementsResolver;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [SettlementsResolver, SettlementsService],
    }).compile();

    resolver = module.get<SettlementsResolver>(SettlementsResolver);
  });

  it('should be defined', () => {
    expect(resolver).toBeDefined();
  });
});
