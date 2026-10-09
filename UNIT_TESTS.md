# KKB Test Plan

Test checklist for the KKB backend (NestJS + Supabase) and frontend (Flutter + Riverpod).

Each case has an **ID**, the input or setup, and the **expected result**. Write the test, run it, and tick the box when it passes. If a case fails, don't change the expected result. Log it under [Reporting results](#reporting-results).

1. [Before you start](#1-before-you-start)
2. [Running the tests](#2-running-the-tests)
3. [Backend unit tests](#3-backend-unit-tests)
4. [Frontend unit and widget tests](#4-frontend-unit-and-widget-tests)
5. [Manual: database functions](#5-manual-database-functions)
6. [Manual: push notifications](#6-manual-push-notifications)
7. [Reporting results](#reporting-results)

---

## 1. Before you start

- [ ] **Install dependencies:** `npm install` in `backend/`, then `flutter pub get` in `frontend/`.
- [ ] **Backend stubs:** the `*.service.spec.ts` and `*.resolver.spec.ts` files that exist now are generated "should be defined" stubs. They fail with `Nest can't resolve dependencies of the XService (?)`. Replace each one with real tests using the patterns in [3.1](#31-setup).
- [ ] **Missing spec:** create `backend/src/notifications/notifications.resolver.spec.ts`. It doesn't exist yet.
- [ ] **Frontend template test:** `frontend/test/widget_test.dart` is the default Flutter counter test and always fails. Delete it.
- [ ] **Frontend dev dependency:** add `mocktail: ^1.0.4` under `dev_dependencies` in `frontend/pubspec.yaml`, then run `flutter pub get`.
- [ ] **Generated models:** if any model has changed, run `dart run build_runner build --delete-conflicting-outputs` in `frontend/` first.

---

## 2. Running the tests

| | Backend (`backend/`) | Frontend (`frontend/`) |
|---|---|---|
| All unit tests | `npm test` | `flutter test` |
| One file / folder | `npx vitest run src/groups` | `flutter test test/utils/helper_test.dart` |
| Watch mode | `npm run test:watch` | — |
| Coverage | `npm run test:cov` | `flutter test --coverage` |
| E2E | `npm run test:e2e` (needs a real `.env` + Supabase) | — |

**Where tests go**
- Backend: next to the code, as `src/**/*.spec.ts`. Vitest runs with `globals: true`, so `describe`/`it`/`expect`/`vi` need no import.
- Frontend: under `frontend/test/`, mirroring `lib/`. For example, `lib/utils/helper.dart` → `test/utils/helper_test.dart`.

---

## 3. Backend unit tests

### 3.1 Setup

#### A fake Supabase client

Every service runs `await this.db.from(...).select(...).eq(...)` and reads `{ data, error }`. This fake returns itself from every chain method and resolves the next queued result when awaited. Results come back **in the order the service awaits its queries**.

Create `backend/test/supabase-mock.ts`:

```ts
import { vi } from 'vitest';

type Result = { data?: unknown; error?: unknown };

const CHAIN_METHODS = ['from', 'select', 'insert', 'update', 'upsert', 'delete', 'eq', 'neq', 'in', 'order', 'single', 'maybeSingle', 'rpc'];

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
```

> Construct services directly (`new GroupsService(db)`), not through `Test.createTestingModule`. The fake is "thenable", and Nest's DI container may await it by accident.

#### Service test pattern

```ts
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

  it('BE-GRP-07 addGroupMember throws NotFound for an unknown code', async () => {
    queue({ data: null }); // groups lookup by code
    await expect(service.addGroupMember('NOPE1234', 'user_1')).rejects.toThrow('Group not found');
  });
});
```

- Check calls with `expect(db.from).toHaveBeenCalledWith('groups')`, `expect(db.insert).toHaveBeenCalledWith({...})` or `expect(db.eq).toHaveBeenCalledWith('user_id', 'user_1')`.
- To test "throws the Supabase error", queue `{ error: { message: 'boom' } }` and assert `rejects.toEqual({ message: 'boom' })`.

**Access checks run first.** Most service methods start with an access check, and that query is awaited first, so queue its result first:
- `assertMember` (`src/auth/membership.ts`) looks up `members`. Queue `{ data: { id: 1 } }` to pass, or `{ data: null }` to get `ForbiddenException('You are not a member of this group')`.
- Group `update` / `remove` / `removeMember` look up the group's `created_by`.
- Settlement `update` / `remove` look up the settlement's `from_user` / `to_user`.
- Expense `update` / `remove` / `findOne` (through the resolver) look up the expense's `group_id`, then run `assertMember`.

#### Resolver test pattern

Resolvers only forward to services. Pass a plain object of `vi.fn()`s:

```ts
const service = { create: vi.fn().mockResolvedValue({ id: 1 }) } as any;
const resolver = new GroupsResolver(service);
await resolver.createGroup({ name: 'Bora' } as any, 'user_1');
expect(service.create).toHaveBeenCalledWith({ name: 'Bora' }, 'user_1');
```

#### Mocking Clerk

```ts
vi.mock('@clerk/backend', () => ({ verifyToken: vi.fn() }));
vi.mock('@clerk/backend/webhooks', () => ({ verifyWebhook: vi.fn() }));
import { verifyToken } from '@clerk/backend';
// later: vi.mocked(verifyToken).mockResolvedValue({ sub: 'user_1' } as any);
```

A fake GraphQL `ExecutionContext` for the guard:

```ts
const gqlContext = (req: any) => ({
  getArgs: () => [{}, {}, { req }, {}],
  getArgByIndex: (i: number) => [{}, {}, { req }, {}][i],
  getClass: () => class {},
  getHandler: () => () => {},
  getType: () => 'graphql',
}) as any;
```

---

### 3.2 `auth/auth.guard.ts` — ClerkGuard

- [ ] **BE-AUTH-01** `Authorization: Bearer abc`, `verifyToken` resolves `{ sub: 'user_1' }` → returns `true` and sets `req.userId = 'user_1'`.
- [ ] **BE-AUTH-02** `verifyToken` is called with `('abc', { secretKey: process.env.CLERK_SECRET_KEY })`. Set `process.env.CLERK_SECRET_KEY = 'sk_test'` in the test.
- [ ] **BE-AUTH-03** No `authorization` header → throws `UnauthorizedException('Missing token')`.
- [ ] **BE-AUTH-04** `Authorization: Bearer ` (empty token) → throws `'Missing token'`.
- [ ] **BE-AUTH-05** `verifyToken` rejects → throws `UnauthorizedException('Invalid or expired token')`, and `req.userId` stays unset.

### 3.3 `auth/current-user.decorator.ts` — CurrentUser

- [ ] **BE-AUTH-06** Returns `req.userId` from the GraphQL context. To reach the factory of a `createParamDecorator`:

  ```ts
  import { ROUTE_ARGS_METADATA } from '@nestjs/common/constants.js';
  function factoryOf(decorator: () => ParameterDecorator) {
    class T { m(@decorator() _v: unknown) {} }
    const args = Reflect.getMetadata(ROUTE_ARGS_METADATA, T, 'm');
    return args[Object.keys(args)[0]].factory;
  }
  expect(factoryOf(CurrentUser)(null, gqlContext({ userId: 'user_1' }))).toBe('user_1');
  ```

  If that import doesn't resolve on this Nest version, mark the case as skipped. The resolver and e2e tests cover it indirectly.

### 3.4 `webhooks/clerk-webhook.controller.ts` — ClerkWebhookController

Build a fake request with `{ rawBody: Buffer.from('{}'), header: (name) => 'value' }` and construct the controller with `new ClerkWebhookController(db)`.

- [ ] **BE-WH-01** `rawBody` missing → `BadRequestException('Missing raw body')`.
- [ ] **BE-WH-02** `verifyWebhook` rejects → `BadRequestException('Invalid webhook signature')`.
- [ ] **BE-WH-03** `verifyWebhook` is called with a `Request` whose headers carry `svix-id`, `svix-timestamp` and `svix-signature`, plus `signingSecret: process.env.CLERK_WEBHOOK_SIGNING_SECRET`.
- [ ] **BE-WH-04** `user.created` with first `Ana`, last `Cruz` → `upsert` into `users` with `display_name: 'Ana Cruz'`, `email` from `email_addresses[0].email_address`, `deleted_at: null` and `{ onConflict: 'id' }`. Returns `{ received: true }`.
- [ ] **BE-WH-05** `user.updated` with only `first_name: 'Ana'` → `display_name: 'Ana'`.
- [ ] **BE-WH-06** No first or last name, `username: 'ana99'` → `display_name: 'ana99'`.
- [ ] **BE-WH-07** The upsert returns an error → the error is thrown (so Clerk retries).
- [ ] **BE-WH-08** `user.deleted` → `users` is updated with `email: null`, `display_name: 'Deleted user'`, the name and image fields `null`, `deleted_at` set to an ISO string, filtered by `.eq('id', id)`.
- [ ] **BE-WH-09** `user.deleted` → also deletes from `user_favorites`, then from `device_tokens`, both with `.eq('user_id', id)`.
- [ ] **BE-WH-10** `user.deleted` where the favorites delete errors → throws, and `device_tokens` is never touched.
- [ ] **BE-WH-11** Any other event type (e.g. `session.created`) → no DB calls, returns `{ received: true }`.
- [ ] **BE-WH-12** `user.created` with `email_addresses: []` → upserts `email: null` without throwing.
- [ ] **BE-WH-13** Two addresses, and `primary_email_address_id` points at the second → the second address is used.

### 3.5 `groups/groups.service.ts` — GroupsService

- [ ] **BE-GRP-01** `generateGroupCode()` returns 8 characters matching `/^[ABCDEFGHJKLMNPQRSTUVWXYZ2-9]{8}$/` (no `0`, `O`, `1` or `I`). Run it ~200 times in a loop.
- [ ] **BE-GRP-02** `create(input, 'user_1')`, happy path. Queue in this order:
  1. code check → `{ data: [] }`
  2. insert group → `{ data: group }`
  3. `addGroupMember` group lookup → `{ data: group }`
  4. member check → `{ data: null }`
  5. member insert → `{ data: member }`
  6. members list → `{ data: [{ users: user }] }`

  Expect: insert called with `{ name, description, avatar_color: input.avatarColor, created_by: 'user_1', code: <8 chars> }`, and the method returns the inserted group.
- [ ] **BE-GRP-03** `create` regenerates the code when the first one exists. First code check → `{ data: [{ id: 9 }] }`, second → `{ data: [] }`. `generateGroupCode` is called twice (spy with `vi.spyOn(service, 'generateGroupCode')`).
- [ ] **BE-GRP-04** `create`: the insert errors → throws, and no member is added.
- [ ] **BE-GRP-04b** `create`: 5 code checks in a row all find a group → `InternalServerErrorException('Could not generate a unique group code')`, and nothing is inserted.
- [ ] **BE-GRP-04c** `create`: `addGroupMember` throws after the insert → the group is deleted (`delete().eq('id', newId)`) and the error is rethrown.
- [ ] **BE-GRP-05** `findUserGroups`: a user with no memberships (`{ data: [] }`) → returns `[]` without querying `groups`.
- [ ] **BE-GRP-06** `findUserGroups` sets `is_favorite: true` when `user_favorites` has rows and `false` when it's `[]`. `created_at` becomes a `Date`, and `members` comes from `getGroupMembersByGroupId`.
- [ ] **BE-GRP-07** `addGroupMember`: unknown code → `NotFoundException('Group not found')`.
- [ ] **BE-GRP-08** `addGroupMember`: already a member → `BadRequestException('User is already a member of the group')`, and nothing is inserted.
- [ ] **BE-GRP-09** `addGroupMember` happy path → inserts `{ group_id, user_id }` and returns the group with `members` and a `Date` `created_at`.
- [ ] **BE-GRP-10** `findFavoriteGroups` strips `user_favorites` and `membership` from the result and sets `is_favorite: true`.
- [ ] **BE-GRP-11** `favoriteGroup`: not favorited yet (`{ data: null }`) → inserts `{ group_id, user_id }`, returns `true`.
- [ ] **BE-GRP-12** `favoriteGroup`: already favorited (`{ data: { id: 5 } }`) → deletes with `.eq('id', 5)`, returns `false`.
- [ ] **BE-GRP-13** `favoriteGroup`: the insert or delete errors → throws.
- [ ] **BE-GRP-14** `removeMember(3, 'user_1', 'user_1')` (leaving) → no creator check, deletes from `members` with `.eq('group_id', 3)` and `.eq('user_id', 'user_1')`, returns `true`.
- [ ] **BE-GRP-14b** `removeMember(3, 'user_2', 'user_1')` where `created_by` is `'user_9'` → `ForbiddenException`, nothing deleted. When `created_by` is `'user_1'` → deleted.
- [ ] **BE-GRP-15** `update` / `remove` / `findGroupMembers` throw on a Supabase error.
- [ ] **BE-GRP-15b** `update` / `remove` by someone who isn't `created_by` → `ForbiddenException('Only the group creator can do this')`. An unknown group → `NotFoundException`.
- [ ] **BE-GRP-15c** `findGroupMembers(3, 'user_1')` for a non-member → `ForbiddenException`. For a member → returns plain `User` objects (not member rows).

### 3.6 `groups/groups.resolver.ts`

- [ ] **BE-GRP-16** Each resolver method forwards to the matching service method with the right arguments:
  - `createGroup(input, userId)` → `create(input, userId)`
  - `updateGroup(input, groupId, userId)` → `update(groupId, input, userId)` (note the order)
  - `addMemberToGroup(code, userId)`, `favoriteGroup(groupId, userId)`, `userGroups(userId)`, `favoriteGroups(userId)`

### 3.7 `expenses/expenses.service.ts` — ExpensesService

- [ ] **BE-EXP-00** `create` / `findAll` by a non-member of the group → `ForbiddenException`, and nothing is inserted.
- [ ] **BE-EXP-01** `create` with `paid_by: 'user_2'` → the insert uses `paid_by: 'user_2'`.
- [ ] **BE-EXP-02** `create` with `paid_by: ''` → falls back to the current user (`paid_by: 'user_1'`).
- [ ] **BE-EXP-03** `create` with 2 splits → one `expense_splits` insert of `[{ expense_id, user_id, amount }, ...]`. Afterwards it re-fetches with `findOne(newId)` and returns that.
- [ ] **BE-EXP-04** `create` with `splits: []` → no `expense_splits` insert.
- [ ] **BE-EXP-05** `create`: the splits insert errors → deletes the expense (`delete().eq('id', newId)`), then throws the splits error.
- [ ] **BE-EXP-06** `create`: the expense insert errors → throws, and no splits are inserted.
- [ ] **BE-EXP-07** `findAll(4)` → `.eq('group_id', 4)` and `.order('created_at', { ascending: false })`.
- [ ] **BE-EXP-08** `update(1, input)` → the payload includes `updated_at` as a `Date`. Use `vi.useFakeTimers()` + `vi.setSystemTime()` for an exact match.
- [ ] **BE-EXP-09** `remove(1)` returns the deleted row (via `.select().single()`).
- [ ] **BE-EXP-09b** `update` / `remove` of an unknown expense → `NotFoundException('Expense not found')`. By a non-member of its group → `ForbiddenException`.
- [ ] **BE-EXP-10** Resolver: `createExpense(input, splits, userId)` → `service.create(input, splits, userId)`, and `updateExpense(input, userId)` → `service.update(input.id, input, userId)`.

### 3.8 `balances/balances.service.ts` — BalancesService

- [ ] **BE-BAL-01** `groupBalances(2)` → `rpc('group_balances', { p_group_id: 2 })`, then `users` with `.in('id', [...the rpc user_ids])`.
- [ ] **BE-BAL-02** The rpc returns `balance` as a string (`'150.50'`, which is how Postgres `numeric` arrives) → the result has `balance: 150.5` as a number.
- [ ] **BE-BAL-03** Each row is `{ user: <matching user object>, balance }`, in rpc order.
- [ ] **BE-BAL-04** The rpc errors → throws. The users query errors → throws.
- [ ] **BE-BAL-05** `totalBalance('user_1')` → `rpc('user_total_balance', { p_user_id: 'user_1' })`, returns the data as-is.
- [ ] **BE-BAL-06** `userGroupBalance(2, 'user_1')` returns that user's balance, or `0` when they're not in the rows.
- [ ] **BE-BAL-07** Resolver: `totalBalance(userId)` uses the current user, and `groupBalances(groupId)` forwards.

### 3.9 `settlements/settlements.service.ts` — SettlementsService

Construct with `new SettlementsService(db, notifications)`, where `notifications = { create: vi.fn() }`.

- [ ] **BE-SET-01** `create(input, userId)` → inserts `{ ...input, status: 'unpaid' }`, even if the input has another status.
- [ ] **BE-SET-02** `recordPayment(input, userId)` → inserts `{ ...input, status: 'pending' }` and calls `notifications.create(from.id, to.id, 'Payment recorded', '<display_name> recorded a payment of ₱500.00')`.
- [ ] **BE-SET-03** `update(7, { id: 7, status: 'paid' }, <to_user>)` → the update payload is `{ status: 'paid' }` (**no `id`**), filtered with `.eq('id', 7)`.
- [ ] **BE-SET-03b** `update` to `paid` or `rejected` by the **payer** → `ForbiddenException('Only the receiver can confirm or reject a payment')`. By someone who is neither payer nor receiver → `ForbiddenException('This settlement is not yours')`.
- [ ] **BE-SET-04** `update` to `status: 'pending'` → calls `notifications.create(from.id, to.id, 'Payment recorded', '<display_name> recorded a payment of ₱500.00')`.
- [ ] **BE-SET-05** `update` to `pending` where `from_user.display_name` is `null` → the message uses `from_user.email`.
- [ ] **BE-SET-06** `update` to `paid` or `rejected` → `notifications.create` is **not** called.
- [ ] **BE-SET-07** `update` errors → throws, and no notification is sent.
- [ ] **BE-SET-08** `findAll(3)` → `.eq('group_id', 3)`, newest first.
- [ ] **BE-SET-09** Resolver: `updateSettlement(input, userId)` → `service.update(input.id, input, userId)`. `recordPayment` / `createSettlement` / `removeSettlement` / `settlements` forward the current user.

### 3.10 `notifications/notifications.service.ts` — NotificationsService

Construct with `new NotificationsService(db, messaging)`, where `messaging = { sendEachForMulticast: vi.fn().mockResolvedValue({ responses: [] }) }`. Firebase is never contacted.

`create` also sends a push, which queries `device_tokens`. After the insert, queue `{ data: [] }` for that lookup, or `{ data: [{ token: 't1' }] }` to make it send.

- [ ] **BE-NOT-01** `create('a', 'b', 'T', 'D')` → inserts `{ from_user: 'a', to_user: 'b', title: 'T', description: 'D' }` and returns the row.
- [ ] **BE-NOT-02** `sendReminder('a', { group_id: 1, to_user: 'b', amount: 1234.5 })` with sender `first_name: 'Ana'` and group `name: 'Boracay'` → title `Payment reminder`, description `Ana reminded you to pay ₱1,234.50 in Boracay`. Queue order: the two membership checks (sender, then receiver), the sender lookup, the group lookup, the insert, then the token lookup.
- [ ] **BE-NOT-03** Sender `first_name: null`, `display_name: 'ana99'` → `ana99 reminded you…`.
- [ ] **BE-NOT-04** The sender query errors → throws, and nothing is inserted. Same for the group query.
- [ ] **BE-NOT-05** Resolver: `sendReminder(input, userId)` → `service.sendReminder(userId, input)` (note the order). Put this in the new `notifications.resolver.spec.ts`.
- [ ] **BE-NOT-07** `create` for a user with tokens `t1` and `t2` → `sendEachForMulticast` is called with `{ tokens: ['t1', 't2'], notification: { title, body: description } }`.
- [ ] **BE-NOT-08** `create` for a user with no tokens (`{ data: [] }`) → `sendEachForMulticast` is not called, and the row is still returned.
- [ ] **BE-NOT-09** `sendEachForMulticast` rejects → `create` still resolves with the row. A push failure must not fail the mutation.
- [ ] **BE-NOT-10** One response has `error.code: 'messaging/registration-token-not-registered'` → `device_tokens` is deleted with `.in('token', [<that token>])`. Tokens that succeeded are kept.
- [ ] **BE-NOT-11** `sendReminder` sends **exactly one** push.
- [ ] **BE-NOT-11b** `sendReminder` where the sender or receiver isn't a member of the group → `ForbiddenException`, nothing inserted or pushed.
- [ ] **BE-NOT-12** `registerDeviceToken('user_1', 'tok')` → first deletes with `.eq('token', 'tok').neq('user_id', 'user_1')`, then upserts `{ user_id: 'user_1', token: 'tok', updated_at: <ISO> }` with `{ onConflict: 'user_id,token' }`, returns `true`.
- [ ] **BE-NOT-12b** `unregisterDeviceToken('user_1', 'tok')` → deletes from `device_tokens` with `.eq('user_id', 'user_1')` and `.eq('token', 'tok')`, returns `true`.
- [ ] **BE-NOT-13** `getUserNotifications('user_1')` → `.eq('to_user', 'user_1')`, newest first.

### 3.11 `users/users.service.ts` — UsersService

- [ ] **BE-USR-01** `remove('user_1')` → updates `{ deleted_at: <ISO string> }` with `.eq('id', 'user_1')` and returns the row. It must **not** call `.delete()`.
- [ ] **BE-USR-02** `update(id, input)` → `users.update(input).eq('id', id)`.
- [ ] **BE-USR-03** `findOne(id)` → `select('*').eq('id', id)`.
- [ ] **BE-USR-04** Every method throws on a Supabase error.
- [ ] **BE-USR-05** Resolver: `findOne` and `removeUser` use the **current user**, never an id from the arguments.

### 3.12 `user-favorites/user-favorites.service.ts` — UserFavoritesService

- [ ] **BE-FAV-01** `create({ group_id: 2 }, 'user_1')` → inserts `{ group_id: 2, user_id: 'user_1' }`. The `user_id` comes from the token, not the input.
- [ ] **BE-FAV-01b** `create` returns the inserted row (`.select().single()`), not `null`.
- [ ] **BE-FAV-02** `findAll('user_1')` → `.eq('user_id', 'user_1')`.
- [ ] **BE-FAV-03** `findOne`, `update` and `remove` filter by `.eq('id', id)` **and** `.eq('user_id', userId)`, return a single row, and throw on error.

### 3.13 Pass-through classes (`parse-amount`, `logger`, `logging`, `app`)

Keep the existing "is defined" specs and add:

- [ ] **BE-MISC-01** `ParseAmountPipe.transform(12.5, meta)` returns `12.5` unchanged.
- [ ] **BE-MISC-02** `LoggerMiddleware.use(req, res, next)` calls `next` exactly once.
- [ ] **BE-MISC-03** `LoggingInterceptor.intercept(ctx, { handle: () => of('x') })` emits `'x'`.
- [ ] **BE-MISC-04** `AppController.getHello()` → `'Hello World!'`.

---

## 4. Frontend unit and widget tests

### 4.1 Setup

#### A fake GraphQL link

All providers call `ref.read(graphqlClientProvider)`. Override that provider with a real `GraphQLClient` on a fake link that answers by operation name, so no network is needed.

Create `frontend/test/helpers/fake_link.dart`:

```dart
import 'package:graphql_flutter/graphql_flutter.dart';

// answers each graphql request by operation name; unknown operations get empty data
class FakeLink extends Link {
  FakeLink(this.responses);

  // operation name -> data to return, or a GraphQLError to fail with
  final Map<String, Object> responses;
  final requests = <Request>[];

  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    requests.add(request);
    final answer = responses[request.operation.operationName] ?? <String, dynamic>{};
    if (answer is GraphQLError) {
      yield Response(errors: [answer], response: const {});
    } else {
      yield Response(data: answer as Map<String, dynamic>, response: const {});
    }
  }
}

GraphQLClient fakeClient(FakeLink link) => GraphQLClient(link: link, cache: GraphQLCache());
```

Use it with a `ProviderContainer`:

```dart
final link = FakeLink({'GroupBalances': {'groupBalances': [ /* ... */ ]}});
final container = ProviderContainer(overrides: [
  graphqlClientProvider.overrideWithValue(fakeClient(link)),
]);
addTearDown(container.dispose);

final res = await container.read(groupBalancesProvider(1).notifier).fetchGroupBalances();
expect(res.status, isTrue);
expect(container.read(groupBalancesProvider(1)).single.amount, 150.5);
// variables sent: link.requests.single.variables
```

Operation names used in the app: `GroupBalances`, `Expenses`, `CreateExpense`, `Settlements`, `CreateSettlement`, `RecordPayment`, `UpdateSettlement`, `SendReminder`, `UserGroups`, `CreateGroup`, `AddMemberToGroup`, `FavoriteGroup`, `RemoveUser`, `UpdateUser`.

#### A JSON fixture for users

```dart
Map<String, dynamic> userJson(String id, {String first = 'Ana'}) => {
  'id': id, 'email': '$id@test.com', 'display_name': first, 'first_name': first,
  'last_name': 'Cruz', 'image_url': '', 'created_at': '2026-01-01T00:00:00Z',
};
```

#### Widget test wrapper

Wrap widgets in `ProviderScope(overrides: [...], child: MaterialApp(home: Scaffold(body: widget)))`.

`currentUserProvider` depends on Clerk. When a widget needs it, override it with `currentUserProvider.overrideWith(() => NoUser())`, where `class NoUser extends CurrentUser { @override build() => null; }`. If the widget takes `userId` as a parameter, pass it directly instead.

---

### 4.2 `utils/helper.dart` — Helper (`test/utils/helper_test.dart`)

- [ ] **FE-HLP-01** `initials('Ana Cruz')` → `'AC'`.
- [ ] **FE-HLP-02** `initials('ana')` → `'AN'`, and `initials('A')` → `'A'`.
- [ ] **FE-HLP-03** `initials('  Ana   Cruz  ')` → `'AC'` (extra spaces are ignored).
- [ ] **FE-HLP-04** `initials('')` and `initials('   ')` → `''`.
- [ ] **FE-HLP-05** `initials('Ana 2nd')` → `'AN'` (the second word doesn't start with a letter).
- [ ] **FE-HLP-06** `colorFromHex('#984063')` → `Color(0xFF984063)`.
- [ ] **FE-HLP-07** `colorFromHex('984063')` (no `#`). **Known limitation:** this gives the wrong color, not `0xFF984063`. Write a test that pins the current result, and note it in your report.
- [ ] **FE-HLP-08** `currency.format(1234.5)` → `'₱1,234.50'`, and `currency.format(0)` → `'₱0.00'`.
- [ ] **FE-HLP-09** `formatDate('2026-10-09T08:00:00Z')` → `'Oct 9'`. With `format: 'yyyy-MM-dd'` → `'2026-10-09'`.
- [ ] **FE-HLP-10** `formatDate('not a date')` → throws `FormatException`.
- [ ] **FE-HLP-11** `getUserBalance` for an expense of 300 paid by A, split A 100 / B 100 / C 100:
  - A → `200`
  - B → `-100`
  - D (not in the splits) → `0`
- [ ] **FE-HLP-12** `getUserBalance` when the payer isn't in the splits (A pays 100, split B 100) → A `100`, B `-100`.
- [ ] **FE-HLP-13** `describe(SocketException('x'))` → `'No internet connection.'`
- [ ] **FE-HLP-14** `describe(TimeoutException('x'))` → `'Request timed out.'`
- [ ] **FE-HLP-15** `describe(http.ClientException('x'))` → `'Could not reach the server.'`
- [ ] **FE-HLP-16** `describe(FormatException('x'))` → `'Unexpected response format.'`
- [ ] **FE-HLP-17** `describe(NetworkException(originalException: SocketException('x'), uri: null))` → `'No internet connection.'`
- [ ] **FE-HLP-18** `describe(StateError('x'))` → starts with `'Unexpected error:'`, and `describe('plain')` → `'plain'`.
- [ ] **FE-HLP-19** `guard(() async => throw SocketException('x'))` → `status: false`, `message: 'No internet connection.'`, `body: {}`.
- [ ] **FE-HLP-20** `guard` returns a successful `ResponseStatus` unchanged.
- [ ] **FE-HLP-21** `error(result)` with `graphqlErrors: [GraphQLError(message: 'Group not found')]` → `'Group not found'`.
- [ ] **FE-HLP-22** `error(result)` with no exception → `'Unknown error'`.
- [ ] **FE-HLP-23** `error(result)` with a `ServerException` whose `parsedResponse.errors` has a message → that message.
- [ ] **FE-HLP-24** `error(result)` with no graphql errors and no link exception → `'Network error. Is the backend/ngrok running?'`

  Build results with `QueryResult(source: QueryResultSource.network, options: QueryOptions(document: gql('query X { x }')), exception: OperationException(...))`.

### 4.3 `utils/storage_helper.dart` + `providers/global/preferred_mode.dart`

Call `SharedPreferences.setMockInitialValues({})` in `setUp`.

- [ ] **FE-STO-01** `getPreferredMode()` with nothing stored → `'light'`.
- [ ] **FE-STO-02** `setPreferredMode('dark')`, then `getPreferredMode()` → `'dark'`.
- [ ] **FE-STO-03** `preferredModeProvider` starts as `'light'`.
- [ ] **FE-STO-04** `notifier.setPreferredMode('dark')` → the state becomes `'dark'` and the value is saved.
- [ ] **FE-STO-05** With `setMockInitialValues({'preferredMode': 'dark'})`, `notifier.getPreferredMode()` → the state becomes `'dark'`.

### 4.4 `providers/auth/auth_provider.dart` — AuthService (mocktail)

Create `class MockClerk extends Mock implements ClerkAuthState {}`, call `registerFallbackValue(Strategy.password)`, and build `AuthService(mockClerk)`.

- [ ] **FE-AUTH-01** `validateEmail('ana@test.com')` → `true`.
- [ ] **FE-AUTH-02** `validateEmail(null)`, `''`, `'ana'`, `'ana@'` and `'ana@test'` → `false`.
- [ ] **FE-AUTH-03** `validateEmail('ana@test.museum')` and `'ana@studio.photography'` → `true`.
- [ ] **FE-AUTH-04** `authLogin`: `attemptSignIn` succeeds and `isSignedIn` is `true` → `status: true`, `message: 'Login Successful'`, and the body has `id`, `email`, `firstName`, `lastName`.
- [ ] **FE-AUTH-05** `authLogin`: `isSignedIn` stays `false` → `status: false`, `'Login incomplete'`.
- [ ] **FE-AUTH-06** `authLogin`: `attemptSignIn` throws a `ClerkError` → `status: false`, and the message is the error's `message`.
- [ ] **FE-AUTH-07** `authSignUp`, signed in right away → `'Sign up Successful'`.
- [ ] **FE-AUTH-08** `authSignUp`, not signed in yet → `status: true`, `'Check your email for a verification code'`, body `{'needsVerification': true}`.
- [ ] **FE-AUTH-09** `authVerifyEmail('123456')` calls `attemptSignUp(strategy: Strategy.emailCode, code: '123456')`, then returns `'Email verified'` or `'Verification incomplete'`.
- [ ] **FE-AUTH-10** `authGetToken` when not signed in → `'Not signed in'`, and `sessionToken()` is never called.
- [ ] **FE-AUTH-11** `authGetToken` when signed in → `body['token']` equals the jwt.
- [ ] **FE-AUTH-12** `authFetchUserInfo` when signed out → `status: false`, `'Not signed in'`, body `{}`.
- [ ] **FE-AUTH-13** `authLogout`: success → `'Logged out'`. Throws → `status: false`.
  `authLogout` calls `unregisterPushToken` first, which touches `FirebaseMessaging.instance`. Firebase isn't initialised in unit tests, so it logs an error and carries on. The test should still pass.
- [ ] **FE-AUTH-14** `authStartPasswordReset('ana@test.com')` calls `initiatePasswordReset(identifier: 'ana@test.com', strategy: Strategy.resetPasswordEmailCode)` and returns `'We sent a reset code to ana@test.com'`.
- [ ] **FE-AUTH-15** `authResetPassword(email, code: '123456', newPassword: 'x')` calls `attemptSignIn(strategy: Strategy.resetPasswordEmailCode, identifier: email, code: '123456', password: 'x')`. Signed in afterwards → `'Password reset'`, otherwise `'Password reset incomplete'`.

### 4.5 `models/` — JSON round trips

- [ ] **FE-MOD-01** `User.fromJson(userJson('u1'))` reads the snake_case keys. With `image_url` / `created_at` missing → defaults to `''`.
- [ ] **FE-MOD-02** `ExpenseInput(...).toJson()` → keys `group_id`, `paid_by`, `description`, `amount`, `splits`. Splits serialize as `{user_id, amount}`.
- [ ] **FE-MOD-03** `SettlementInput(...).toJson()` → `{from_user, to_user, amount}`.
- [ ] **FE-MOD-04** `Settlement` defaults `status` to `'unpaid'`.
- [ ] **FE-MOD-05** `Group` defaults: `avatarColor '#984063'`, `isFavorite false`, `members []`.
- [ ] **FE-MOD-06** `copyWith(isFavorite: true)` changes only that field.

### 4.6 `providers/groups/group_balances.dart` — GroupBalances

- [ ] **FE-PRV-BAL-01** A successful fetch maps `{user, balance}` into `Balance(user, groupId, amount)`. A `balance` of `150` (int) becomes `150.0`.
- [ ] **FE-PRV-BAL-02** The request sends `variables: {'groupId': 1}`.
- [ ] **FE-PRV-BAL-03** A GraphQL error → `status: false`, the message comes from the error, and the state stays `[]`.
- [ ] **FE-PRV-BAL-04** Fetching group 1 doesn't change `groupBalancesProvider(2)`.

### 4.7 `providers/groups/group_expenses.dart` — GroupExpenses

- [ ] **FE-PRV-EXP-01** `parseExpense` maps `paid_by` and `splits[].user`. Missing `description` → `''`, missing `amount` → `0`.
- [ ] **FE-PRV-EXP-02** `fetchGroupExpenses(3)` sets the state in server order and returns `status: true`.
- [ ] **FE-PRV-EXP-03** `createExpense`: the `input` variable has **no** `splits` key, and the `splits` variable is `[{user_id, amount}]`.
- [ ] **FE-PRV-EXP-04** `createExpense` adds the new expense to the start of the state (newest first).
- [ ] **FE-PRV-EXP-05** `createExpense` triggers a `GroupBalances` request for `expenseInput.groupId` (check `link.requests`).
- [ ] **FE-PRV-EXP-06** `createExpense` with an error → `status: false`, the state is unchanged, and there's no balances refetch.
- [ ] **FE-PRV-EXP-07** An expense whose split user is a deleted user (`email: null`, `first_name: null`, `image_url: null`) → parses with `''` for those fields, and the fetch succeeds.

### 4.8 `providers/groups/group_settlements.dart` — GroupSettlements

- [ ] **FE-PRV-SET-01** `parseSettlement` parses `created_at` into a `DateTime`. A missing `status` → `'unpaid'`.
- [ ] **FE-PRV-SET-02** `createSettlement` and `recordPayment` send `input` = `{from_user, to_user, amount, group_id}` with the family's `groupId`.
- [ ] **FE-PRV-SET-03** `recordPayment` adds the result to the start of the state, and the message is `'Payment recorded'`.
- [ ] **FE-PRV-SET-04** `updateSettlementStatus(s, 'paid')` sends `{id, status}`, replaces **only** that settlement in the state (order kept), and refetches `GroupBalances`.
- [ ] **FE-PRV-SET-05** `sendReminder(user, 250)` sends `{group_id, to_user: user.id, amount: 250}`. The message is `'Reminder sent to <firstName>'`.
- [ ] **FE-PRV-SET-06** Each mutation with an error → `status: false`, and the state is unchanged.

### 4.9 `providers/groups/user_groups.dart` — UserGroups

- [ ] **FE-PRV-GRP-01** `fetchUserGroups` sorts by `created_at`, newest first.
- [ ] **FE-PRV-GRP-02** `createdBy` is the member whose id equals `created_by`. When the creator isn't a member → `null`, with no throw.
- [ ] **FE-PRV-GRP-03** `fetchUserGroups` sets `selectedGroupProvider` to the first group **only if** nothing is selected yet. Pre-select a group and check it stays selected.
- [ ] **FE-PRV-GRP-04** `addMemberToGroup('ABCD2345')` adds the joined group to the start of the state.
- [ ] **FE-PRV-GRP-05** `addMemberToGroup` with a `null` result → `status: false`, `'No group found'`.
- [ ] **FE-PRV-GRP-06** `toggleFavorite`: the server returns `true` → the state ends with `isFavorite: true`, and the message is `'Added to favorites'`.
- [ ] **FE-PRV-GRP-07** `toggleFavorite`: the server errors → `isFavorite` goes **back** to its previous value.
- [ ] **FE-PRV-GRP-08** `toggleFavorite`: the state flips **before** the request finishes. Use a link that awaits a `Completer`.
- [ ] **FE-PRV-GRP-09** `createGroup` sends `name`, `description` and `avatarColor`, then refetches `UserGroups`.
- [ ] **FE-PRV-GRP-10** A member with `image_url: null` (or any null user field) → parsing the group doesn't throw.
- [ ] **FE-PRV-GRP-11** The `AddMemberToGroup` query selects `code`, and the joined group in state has that code.

### 4.10 `providers/groups/selected_group.dart` — SelectedGroup

- [ ] **FE-PRV-SEL-01** Starts as `null`.
- [ ] **FE-PRV-SEL-02** `setSelectedGroup(group)` sets the state, then sends `GroupBalances`, `Expenses` and `Settlements` requests for that group id.

### 4.11 `providers/settings/user_profile.dart` — UserProfileSettings

- [ ] **FE-PRV-USR-01** `updateUserProfile(...)` sends `input: {id, first_name, last_name, display_name}`. The success message is `'Profile updated successfully'`.
- [ ] **FE-PRV-USR-02** `deleteUserProfile()` sends the `RemoveUser` mutation with no variables. The success message is `'Account deleted successfully'`.
- [ ] **FE-PRV-USR-03** Both return `status: false` with the server message on error.

### 4.12 Debt calculations

The suggested-payment and debt calculations are private methods inside widgets:

- `getSuggestedPayments` in [`components/balances/index.dart`](frontend/lib/components/balances/index.dart)
- `debtsOf` in [`components/settle/record_payment_card.dart`](frontend/lib/components/settle/record_payment_card.dart)

Test them through widget tests of `BalancesIndex` and `RecordPaymentCard`. If they've been moved into pure functions (e.g. `lib/utils/debts.dart`), test those directly.

Members are A, B and C throughout:

- [ ] **FE-DEBT-01** A pays 300, split 100 each → suggestions `B→A 100` and `C→A 100`. No `A→A`.
- [ ] **FE-DEBT-02** Add: B pays 60, split A 30 / B 30 → `B→A 70` (netted, not `B→A 100` + `A→B 30`).
- [ ] **FE-DEBT-03** Add a **paid** settlement B→A 70 → no B↔A suggestion.
- [ ] **FE-DEBT-04** A **pending** or **rejected** settlement B→A 70 doesn't count → `B→A 70` remains.
- [ ] **FE-DEBT-05** A net of `0.004` → skipped (under the 0.01 threshold). Amounts are rounded to 2 decimal places.
- [ ] **FE-DEBT-06** No expenses → `[]`.
- [ ] **FE-DEBT-07** With FE-DEBT-02's data, `debtsOf('B')` → `{A: 70}`, and `debtsOf('A')` → `{B: -70, C: -100}`.
- [ ] **FE-DEBT-08** `RecordPaymentCard` lists only the members the payer owes at least `0.005`. When they owe no one, the hint reads `'Owes no one'`.

### 4.13 Widget tests (`test/components/...`)

**`NetBalanceCard`**
- [ ] **FE-W-01** `balance: -250` → shows `−₱250.00` (the sign is U+2212 `−`, not a hyphen), `'You owe overall'`, `'Owed to you ₱0.00'` and `'You owe ₱250.00'`.
- [ ] **FE-W-02** `balance: 120` → `+₱120.00`, `"You're owed overall"`.
- [ ] **FE-W-03** `balance: 0` → `₱0.00`, `'All settled up'`.

**`BalanceLabel`**
- [ ] **FE-W-04** `-50` → `'You owe'` and `'₱50.00'` in the owe color. `50` → `"You're owed"`. `0` → `'All settled up'`.

**`CustomSplit`**
- [ ] **FE-W-05** `amount 3600`, `assigned 3000` → `'₱600.00 left'`.
- [ ] **FE-W-06** `assigned 3700` → `'₱100.00 over'`.
- [ ] **FE-W-07** `assigned 3600` → `'₱0.00 left'` with a check icon, and `'₱3,600.00 of ₱3,600.00 assigned'`.
- [ ] **FE-W-08** Typing in a member's field calls `onChanged`. An empty `members` list → `'No members to split with.'`

**`EqualSplit`**
- [ ] **FE-W-09** `equalShare: 100` → `'₱100.00 each'`. Unselected members show `'—'`.
- [ ] **FE-W-10** Tapping a member calls `onToggle(member.id)`.

**`expenseAmountFormatter`**
- [ ] **FE-W-11** Allows `'3600'` and `'3600.50'`. Rejects `'3600.555'`, `'abc'` and `'1.2.3'`. Test by entering text into a `TextField` that uses the formatter.

**`SummaryCard`**
- [ ] **FE-W-12** 3 expenses totalling 500, one paid settlement of 100 and two unpaid/pending → `'₱500.00'` and `'3 expenses · ₱100.00 settled · 2 pending'`.
- [ ] **FE-W-13** No pending settlements → the `· N pending` part is hidden.
- [ ] **FE-W-14** Members are ordered by amount paid, highest first.

**`MemberAvatar`**
- [ ] **FE-W-15** `colorIndexIn(members, 'missing')` → `0`, and `colorIndexIn(members, members[2].id)` → `2`.
- [ ] **FE-W-16** An empty `imageUrl` → shows the initials from `firstName lastName`.

**`SuggestedPaymentCard`** (wrap in `ProviderScope`)
- [ ] **FE-W-17** `payment.from.id == userId` → title `'You pay <to>'` and a `'Settle up'` button.
- [ ] **FE-W-18** `payment.to.id == userId` → a `'Remind'` button. Tapping it shows `'Sending…'` and disables it until the `SendReminder` mutation completes, then shows a snackbar.
- [ ] **FE-W-19** A payment between two other people → no button.

**`PaymentHistoryCard` / `ConfirmationCard`** (override `selectedGroupProvider`, `groupSettlementsProvider` and `currentUserProvider`)
- [ ] **FE-W-20** No settlements → `'No payments yet'`.
- [ ] **FE-W-21** The status pills read `Paid`, `Pending`, `Rejected` and `Unpaid`, and the current user shows as `You`.
- [ ] **FE-W-22** `ConfirmationCard` shows only `pending` settlements **to** the current user, at most 3 rows, with an `'N pending'` pill. It's hidden when there are none.

**`JoinCreateGroupPanel`**
- [ ] **FE-W-23** Create with an empty name → snackbar `'Group name is required'`. An empty description → `'Description is required'`.
- [ ] **FE-W-24** Color `'12345'` or `'GGGGGG'` → shows the color error and sends no request. `'abcdef'` → sends `avatarColor: '#ABCDEF'`.

**`AddExpensesIndex`** (override `selectedGroupProvider` with a 3-member group)
- [ ] **FE-W-25** The submit button is disabled until there's a description, an amount > 0 and at least one member selected.
- [ ] **FE-W-26** Custom split: the button stays disabled until the custom total equals the amount (±0.01).
- [ ] **FE-W-27** Equal split of 300 between 3 → the `CreateExpense` splits are `100` each. Members with a 0 share are left out.
- [ ] **FE-W-28** Equal split of 100 between 3 → the splits are `33.34, 33.33, 33.33` (total exactly `100`). The extra centavo goes to the first member in the list.

### 4.14 Router redirect (`core/router.dart`) — optional

Fake `ClerkAuthState` with mocktail (`isSignedIn`, plus `addListener` / `removeListener` for `refreshListenable`):

- [ ] **FE-RT-01** Signed out, any route → `/login`.
- [ ] **FE-RT-02** Signed in, on `/login` → `/groups`.
- [ ] **FE-RT-03** Signed in, `/group/balances` with no selected group → `/groups`.
- [ ] **FE-RT-04** Signed in, `/group/balances` with a group selected → stays.

---

## 5. Manual: database functions

The balance math (`group_balances`, `user_total_balance` in `supabase/schema.sql`) runs in Postgres, so the unit tests can't reach it. Run these in the Supabase SQL editor on a **scratch project**, or inside a `begin; … rollback;` block so nothing is saved. Members are A, B and C.

- [ ] **DB-01** A pays 300, split 100/100/100 → A `+200`, B `-100`, C `-100`. The sum is `0`.
- [ ] **DB-02** Add: B pays 60, split A 30 / B 30 → A `+170`, B `-70`, C `-100`.
- [ ] **DB-03** Add a settlement B→A 70 with status `pending` → balances unchanged.
- [ ] **DB-04** Change it to `paid` → B `0`, A `+100`.
- [ ] **DB-05** Change it to `rejected` → back to the DB-02 numbers.
- [ ] **DB-06** `user_total_balance(A)` across two groups equals the sum of A's balance in each.
- [ ] **DB-07** A member with no expenses → balance `0` (not `null`).

---

## 6. Manual: push notifications

Check that a reminder shows up as a system notification on the debtor's phone while the app is **not open**.

### What you need

- **Backend:** `backend/.env` has `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL` and `FIREBASE_PRIVATE_KEY` from a Firebase service account. Both phones must be able to reach the backend (e.g. through ngrok).
- **Two Android devices:** two phones, or a phone and an emulator. An emulator must use a **Google Play** system image. iOS isn't set up for push, so use Android.
- **Two accounts:** **Ana** is owed money and **Ben** owes it. Sign Ana in on device 1 and Ben on device 2.
- When the app asks to allow notifications, tap **Allow** on both devices. On Android 13+ this prompt appears after sign-in.

### Setup

- [ ] **NT-01** Both devices are registered. In the Supabase SQL editor, run:
  ```sql
  select u.display_name, t.token, t.updated_at
  from device_tokens t join users u on u.id = t.user_id;
  ```
  Expect at least one row each for Ana and Ben. If one is missing, check the app logs for `FCM token not registered` or `FCM token not saved`.
- [ ] **NT-02** Ana creates a group (e.g. "Boracay") and shares the invite code. Ben joins with the code. Both see each other in the member list.
- [ ] **NT-03** Ana adds an expense: ₱200, paid by Ana, split equally between Ana and Ben. On the Balances tab, both phones show **Ben → Ana ₱100.00**.

### Send the reminder

- [ ] **NT-04** On Ben's phone, leave the app: press Home, or swipe it away from recent apps.
  Don't use **Settings → Apps → Force stop**. Android blocks notifications to force-stopped apps until they're opened again.
- [ ] **NT-05** On Ana's phone, open Balances. The Ben → Ana card shows a **Remind** button. Tap it. The button shows `Sending…`, then a snackbar reads `Reminder sent to Ben`.
- [ ] **NT-06** Within a few seconds Ben's phone shows a notification, **once**:
  - Title: `Payment reminder`
  - Body: `Ana reminded you to pay ₱100.00 in Boracay`
- [ ] **NT-07** Tapping the notification opens the app on the normal start screen.
- [ ] **NT-08** Ben's notifications screen lists the reminder. In SQL, `select * from notifications order by created_at desc limit 1;` shows `from_user` = Ana, `to_user` = Ben.

### Edge cases

- [ ] **NT-09** **App open:** with the app open on Ben's phone, Ana sends another reminder. Expect **no** system notification. The reminder still appears on the notifications screen after a refresh.
- [ ] **NT-10** **Only the person owed can remind:** on Ben's phone, the same card shows **Settle up**, not Remind. A third member who isn't part of that payment sees no button.
- [ ] **NT-11** **Permission denied:** turn off notifications for KKB in Ben's Android settings, then send a reminder. No notification appears, but the reminder still succeeds and the row is saved.
- [ ] **NT-12** **Uninstalled app:** uninstall KKB on Ben's phone, then send a reminder. Ben's token disappears from the NT-01 query.
- [ ] **NT-13** **Signed out:** sign Ben out on device 2. That device disappears from Ben's rows in the NT-01 query. Send a reminder: nothing arrives on device 2.
- [ ] **NT-14** **Account switch:** after NT-13, sign in as a third user on device 2. The device's token now belongs only to that user, and Ben's reminders don't arrive there.
- [ ] **NT-15** **Payment recorded:** with Ana's app in the background, Ben records a ₱100 payment to Ana. Ana gets `Payment recorded` / `Ben … recorded a payment of ₱100.00`.
- [ ] **NT-16** **Debt settled:** Ben records a ₱100 payment and Ana confirms it. The Ben → Ana suggestion disappears, so there's no Remind button.

### If nothing arrives

1. Check the backend logs for `Push to <userId> failed: ...`. A credential error points to the `FIREBASE_*` values in `.env`.
2. Copy Ben's token from `device_tokens`. In the Firebase console, go to **Messaging → New campaign → Send test message** and send to that token. If it arrives, the problem is in the backend. If not, it's the device or Firebase setup.
3. Check that `frontend/android/app/google-services.json` is from the same Firebase project as the backend's service account.
4. On an emulator, check that the system image says "Google Play" and that a Google account is signed in.

---

## Reporting results

For each failing or skipped case, send:

| Field | Example |
|---|---|
| ID | `BE-SET-04` |
| Result | Fail / Skipped |
| Expected | `notifications.create` called once |
| Actual | Not called |
| Details | Error output, screenshot, or device + Android version for manual tests |

Also include the final summary line from `npm test` and `flutter test`.
