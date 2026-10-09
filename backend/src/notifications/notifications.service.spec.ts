import { createSupabaseMock } from '../../test/supabase-mock.js';
import { NotificationsService } from './notifications.service.js';

describe('NotificationsService', () => {
  let db: any;
  let queue: (...r: any[]) => void;
  let service: NotificationsService;

  beforeEach(() => {
    ({ db, queue } = createSupabaseMock());
    service = new NotificationsService(db, { send: vi.fn() } as any);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
