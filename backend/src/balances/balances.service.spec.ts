import { createSupabaseMock } from '../../test/supabase-mock.js';
import { BalancesService } from './balances.service.js';

describe('BalancesService', () => {
  let db: any;
  let queue: (...r: any[]) => void;
  let service: BalancesService;

  beforeEach(() => {
    ({ db, queue } = createSupabaseMock());
    service = new BalancesService(db);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
