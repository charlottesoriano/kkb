import { createSupabaseMock } from '../../test/supabase-mock.js';
import { GroupsService } from './groups.service.js';

describe('GroupsService', () => {
  let db: any;
  let queue: (...r: any[]) => void;
  let service: GroupsService;

  beforeEach(() => {
    ({ db, queue } = createSupabaseMock());
    service = new GroupsService(db);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
