import { createSupabaseMock } from '../../test/supabase-mock.js';
import { UserFavoritesService } from './user-favorites.service.js';

describe('UserFavoritesService', () => {
  let db: any;
  let queue: (...r: any[]) => void;
  let service: UserFavoritesService;

  beforeEach(() => {
    ({ db, queue } = createSupabaseMock());
    service = new UserFavoritesService(db);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
