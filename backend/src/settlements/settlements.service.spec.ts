import { createSupabaseMock } from '../../test/supabase-mock.js';
import { SettlementsService } from './settlements.service.js';

describe('SettlementsService', () => {
  let db: any;
  let queue: (...r: any[]) => void;
  let service: SettlementsService;

  beforeEach(() => {
    ({ db, queue } = createSupabaseMock());
    service = new SettlementsService(db, { create: vi.fn() } as any);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
