import { createSupabaseMock } from '../../test/supabase-mock.js';
import { UsersService } from './users.service.js';

describe('UsersService', () => {
  let db: any;
  let queue: (...r: any[]) => void;
  let service: UsersService;

  beforeEach(() => {
    ({ db, queue } = createSupabaseMock());
    service = new UsersService(db);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
