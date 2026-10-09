import { vi } from 'vitest';

type Result = { data?: unknown; error?: unknown };

const CHAIN_METHODS = ['from', 'select', 'insert', 'update', 'upsert', 'delete', 'eq', 'in', 'order', 'single', 'maybeSingle', 'rpc'];

// a fake supabase client: every query method returns the same builder, and awaiting it
// resolves the next queued result, so queue results in the order the service awaits them
export function createSupabaseMock() {
  const results: Result[] = [];
  const db: any = {};
  for (const method of CHAIN_METHODS) db[method] = vi.fn(() => db);
  db.then = (resolve: any, reject: any) =>
    Promise.resolve({ data: null, error: null, ...results.shift() }).then(resolve, reject);

  return {
    db,
    // queue the { data, error } each awaited query should return
    queue: (...next: Result[]) => results.push(...next),
  };
}
