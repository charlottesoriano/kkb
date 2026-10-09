import { createSupabaseMock } from '../../test/supabase-mock.js';
import { ExpensesService } from './expenses.service.js';

describe('ExpensesService', () => {
  let db: any;
  let queue: (...r: any[]) => void;
  let service: ExpensesService;

  beforeEach(() => {
    ({ db, queue } = createSupabaseMock());
    service = new ExpensesService(db);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
