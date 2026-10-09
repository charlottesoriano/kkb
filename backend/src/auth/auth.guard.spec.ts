import { ClerkGuard } from './auth.guard.js';

describe('ClerkGuard', () => {
  it('should be defined', () => {
    expect(new ClerkGuard()).toBeDefined();
  });
});
