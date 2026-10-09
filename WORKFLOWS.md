# KKB Workflows

This document describes every user-facing and system workflow in KKB: what starts it, what happens on the frontend and the backend, what changes in the database, and which rules apply.

KKB is a group expense-splitting app. Members of a group log shared expenses, see who owes whom, record payments to each other, and confirm the payments they receive.

---

## Contents

1. [Architecture at a glance](#1-architecture-at-a-glance)
2. [Core concepts](#2-core-concepts)
3. [Authentication workflows](#3-authentication-workflows)
   - 3.1 Sign up with email and password
   - 3.2 Sign in with email and password
   - 3.3 Sign in or sign up with Google
   - 3.4 Reset a forgotten password
   - 3.5 Session restore on app launch
   - 3.6 Authenticated requests
   - 3.7 Sign out
4. [User sync workflows](#4-user-sync-workflows)
   - 4.1 Clerk webhook: user created or updated
   - 4.2 Clerk webhook: user deleted
   - 4.3 Fallback user sync
5. [Group workflows](#5-group-workflows)
   - 5.1 Load the groups list
   - 5.2 Create a group
   - 5.3 Join a group with an invite code
   - 5.4 Favorite or unfavorite a group
   - 5.5 Open a group
   - 5.6 Share the invite code
6. [Expense workflows](#6-expense-workflows)
   - 6.1 View expenses
   - 6.2 Add an expense
7. [Balance workflows](#7-balance-workflows)
   - 7.1 Net balance per member
   - 7.2 Suggested payments
8. [Settlement workflows](#8-settlement-workflows)
   - 8.1 Settlement lifecycle
   - 8.2 Record a payment
   - 8.3 Confirm or reject a payment
   - 8.4 Settle-up summary and payment history
9. [Notification workflows](#9-notification-workflows)
   - 9.1 Register a device for push notifications
   - 9.2 Send a payment reminder
   - 9.3 How a notification is delivered
   - 9.4 View notifications
10. [Profile and account workflows](#10-profile-and-account-workflows)
    - 10.1 Edit profile
    - 10.2 Delete account
11. [Data refresh rules](#11-data-refresh-rules)
12. [Error handling](#12-error-handling)
13. [Backend operations not used by the app](#13-backend-operations-not-used-by-the-app)
14. [Known gaps and inconsistencies](#14-known-gaps-and-inconsistencies)

---

## 1. Architecture at a glance

| Layer | Technology | Where |
|---|---|---|
| Mobile app | Flutter, Riverpod for state, go_router for navigation, graphql_flutter as the API client | [frontend/lib/](frontend/lib/) |
| Authentication | Clerk: sessions, email/password, Google OAuth, email verification | Clerk SDK in the app; JWT checks in [auth.guard.ts](backend/src/auth/auth.guard.ts) |
| API | NestJS with a code-first GraphQL API served at `/graphql`, plus one REST webhook at `POST /webhooks/clerk` | [backend/src/](backend/src/) |
| Database | Supabase (Postgres), accessed with the service key | [schema.sql](backend/supabase/schema.sql) |
| Push notifications | Firebase Cloud Messaging (FCM) | [firebase.provider.ts](backend/src/notifications/firebase.provider.ts), [push.dart](frontend/lib/core/push.dart) |

**Request path:** a screen widget calls a Riverpod provider method. The provider sends a GraphQL query or mutation with `Authorization: Bearer <Clerk JWT>`. `ClerkGuard` verifies the token and stores the user id on the request. The resolver passes that id (`@CurrentUser()`) to a service. The service checks permissions, queries Supabase, and returns the result. The provider then updates its state, and every widget watching that provider rebuilds.

**Navigation** ([router.dart](frontend/lib/core/router.dart)):

```
/login, /signup                     public; signed-in users are redirected to /groups
/notifications                      full screen
Main navigation (bottom bar)
  /groups                           Groups list
  /settings                         Settings
Group navigation (bottom bar, needs a selected group)
  /group/balances                   Balances
  /group/expenses                   Expenses
    /group/expenses/add             Add expense (full screen)
  /group/settle                     Settle up
```

Redirect rules: a signed-out user is sent to `/login`. A signed-in user on `/login` or `/signup` is sent to `/groups`. Any `/group/*` route with no selected group (for example after a hot restart) is sent to `/groups`. The router re-runs these rules whenever Clerk's auth state changes.

---

## 2. Core concepts

| Concept | Table | Meaning |
|---|---|---|
| User | `users` | Mirror of a Clerk user. `id` is the Clerk user id. Soft-deleted with `deleted_at`. |
| Group | `groups` | A shared ledger with a unique 8-character invite `code`, a name, a description, and an avatar color. `created_by` is the creator. |
| Member | `members` | Links a user to a group. Unique per `(group_id, user_id)`. |
| Expense | `expenses` | A bill of `amount` paid by one member (`paid_by`). |
| Expense split | `expense_splits` | One member's share of an expense. The payer's own share is included. |
| Settlement | `settlements` | A payment from `from_user` to `to_user`, with a `status` of `unpaid`, `pending`, `paid` or `rejected`. Not linked to any expense. |
| Notification | `notifications` | An in-app message from one user to another, also sent as a push notification. |
| Device token | `device_tokens` | An FCM token for a device the user is signed in on. |
| Favorite | `user_favorites` | A group the user starred. |

**Balance sign convention:** a positive balance means the group owes the member money. A negative balance means the member owes the group.

**Currency:** Philippine peso (₱). Amounts are `numeric(12,2)`.

---

## 3. Authentication workflows

All Clerk calls go through `AuthService` in [auth_provider.dart](frontend/lib/providers/auth/auth_provider.dart). Clerk reports errors on its own error stream, and `ClerkErrorListener` shows them as snackbars. `_clerkCall` listens to that stream and marks the result with `errorShown: true`, so the screen does not show the same error twice.

### 3.1 Sign up with email and password

**Screen:** [signup/index.dart](frontend/lib/components/signup/index.dart)

1. The user enters a first name, last name, email and password.
2. The app validates the form: the first name is required, the email must match a pattern, and the password strength must be at least 3.
3. `authSignUp` calls Clerk `attemptSignUp` with the password strategy.
4. If Clerk requires email verification, the app requests an email code (`Strategy.emailCode`) and the screen switches to the verification step.
5. The user enters the 6-digit code. `authVerifyEmail` submits it to Clerk.
   - **Resend code** calls `authResendVerificationCode`.
   - **Back** leaves the verification step.
6. Once Clerk reports the user as signed in, `_syncBackendUser` calls the `syncUser` mutation (see [4.3](#43-fallback-user-sync)).
7. The router sees the signed-in state and redirects to `/groups`.

### 3.2 Sign in with email and password

**Screen:** [signin/index.dart](frontend/lib/components/signin/index.dart)

1. The app validates the email format and checks that the password is not empty.
2. `authLogin` calls Clerk `attemptSignIn` with the password strategy.
3. On success the router redirects to `/groups`. On failure the screen shows the error, unless Clerk already showed it.

### 3.3 Sign in or sign up with Google

**Used by:** both the sign-in and sign-up screens, through `authGoogleSignIn`.

1. Clerk `ssoSignIn` opens the Google OAuth flow.
2. If the Google account has no Clerk user yet, Clerk returns a "transferable" sign-in. The app converts it into a sign-up by calling `/client/sign_ups` with `transfer: true`.
3. If the user ends up signed in, the app calls `syncUser` so the backend has a `users` row. An existing row is left unchanged.
4. If the user closes the Google page, the result is "Google sign-in cancelled".

### 3.4 Reset a forgotten password

**Screens:** [signin/index.dart](frontend/lib/components/signin/index.dart), [reset_password_dialog.dart](frontend/lib/components/signin/reset_password_dialog.dart)

1. The user types an email on the sign-in screen and taps "Forgot password". The email must be valid.
2. `authStartPasswordReset` asks Clerk to email a reset code.
3. A dialog asks for the 6-digit code and a new password.
4. `authResetPassword` calls Clerk `attemptSignIn` with `resetPasswordEmailCode`. When it succeeds, Clerk signs the user in.
5. The dialog closes and the app navigates to `/groups`.

### 3.5 Session restore on app launch

**Code:** [main.dart](frontend/lib/main.dart)

1. The app loads `.env`, which holds `CLERK_PUBLISHABLE_KEY` and `API_BASE_URL`.
2. `ClerkAuthState.create` restores any saved session, so a returning user is already signed in.
3. Firebase is initialised. If that fails, push notifications are disabled and the rest of the app still works.
4. `MyApp` listens to `currentUserProvider`. When a user appears or changes, it registers the device for push notifications ([9.1](#91-register-a-device-for-push-notifications)).
5. When the main navigation first renders, [navigation.dart](frontend/lib/components/navigation.dart) loads the user's groups and notifications in parallel.

### 3.6 Authenticated requests

- **Client side:** [graphql_client.dart](frontend/lib/providers/global/graphql_client.dart) adds `Authorization: Bearer <jwt>` to every request. `authGetToken` gets the JWT from Clerk `sessionToken()`, which reuses the cached token until it expires (about one minute). The client also sends `ngrok-skip-browser-warning: true` so requests work through an ngrok tunnel.
- **Server side:** every resolver uses `@UseGuards(ClerkGuard)`. The guard verifies the JWT with `CLERK_SECRET_KEY` and sets `req.userId` to the token's `sub` claim. `@CurrentUser()` reads that value. A missing or invalid token returns `401 Unauthorized`.
- **Membership check:** most group-scoped services call `assertMember(db, groupId, userId)` from [membership.ts](backend/src/auth/membership.ts). It returns `403 Forbidden` unless the user is a member of the group.

### 3.7 Sign out

**Screen:** [settings/index.dart](frontend/lib/components/settings/index.dart)

1. `authLogout` first calls `unregisterDeviceToken` for this device's FCM token, while the session can still authenticate. It then deletes the local FCM token.
2. Clerk `signOut` ends the session, and the router redirects to `/login`.
3. The Settings screen clears `userGroupsProvider` and `graphqlClientProvider`. Both providers stay alive for the whole session, so without this step the next user to sign in would see this user's groups and cached queries.

---

## 4. User sync workflows

A `users` row must exist before the user can be added to `members`, because of the foreign key. The app has three ways to create one.

### 4.1 Clerk webhook: user created or updated

**Code:** [clerk-webhook.controller.ts](backend/src/webhooks/clerk-webhook.controller.ts)

1. Clerk sends `POST /webhooks/clerk`. The app is created with `rawBody: true` so the signature can be checked against the raw body.
2. The controller verifies the Svix signature with `CLERK_WEBHOOK_SIGNING_SECRET`. An invalid signature returns `400`.
3. For `user.created` and `user.updated`, it upserts the `users` row with the email (primary address first, can be null), the display name (first and last name, or the username), the first and last name, and the image URL. It also clears `deleted_at`.
4. A database error returns a non-2xx response, which makes Clerk retry the webhook.

### 4.2 Clerk webhook: user deleted

1. For `user.deleted`, the controller anonymises the `users` row: the email, names and image become null, the display name becomes "Deleted user", and `deleted_at` is set. The row is kept so that expenses the user paid still point at a valid `paid_by`.
2. It deletes the user's `user_favorites` and `device_tokens` rows, which are personal data and not part of shared group history.

### 4.3 Fallback user sync

The webhook can arrive late, or never if the backend is not publicly reachable. There are two fallbacks:

- **`syncUser` mutation** ([users.service.ts](backend/src/users/users.service.ts)): the app calls it after sign-up, email verification and Google sign-in. It fetches the user from Clerk and inserts the row with `ignoreDuplicates`. An existing row is never overwritten, so a display name the user changed in Settings is kept.
- **`ensureUserExists`** ([groups.service.ts](backend/src/groups/groups.service.ts)): runs before a member is added to a group. If no `users` row exists, it copies the user from Clerk.

---

## 5. Group workflows

**State:** [user_groups.dart](frontend/lib/providers/groups/user_groups.dart), [selected_group.dart](frontend/lib/providers/groups/selected_group.dart)
**Backend:** [groups.service.ts](backend/src/groups/groups.service.ts)

### 5.1 Load the groups list

**Screen:** [groups/index.dart](frontend/lib/components/groups/index.dart)

1. `fetchUserGroups` runs the `userGroups` query with the `networkOnly` fetch policy.
2. The backend finds the user's memberships and returns those groups. Each group includes its full member list and an `is_favorite` flag for the current user.
3. The app sorts the groups newest first. If one of them is the selected group, the selected group is replaced with the fresh copy so new members appear.
4. The screen filters by the search text (a case-insensitive match on the name) and shows three sections:
   - **Favorites:** a horizontal carousel. Each card loads that group's balances and settlements, and shows your balance plus the number of payments waiting for your confirmation.
   - **My groups:** groups you created.
   - **Joined groups:** groups other people created.
5. Pull to refresh runs `fetchUserGroups` again.

### 5.2 Create a group

**Screen:** [join_create_group_panel.dart](frontend/lib/components/groups/join_create_group_panel.dart), opened from the header "+" button or the dashed button at the bottom.

1. The user enters a name and a description, and picks a color from the presets or types a 6-character hex value.
2. The app validates the input: the name and description are required, and the color must be valid hex.
3. The `createGroup` mutation runs.
4. Backend steps:
   1. It generates an 8-character code from `A-Z` and `2-9`, leaving out look-alike characters (0/O, 1/I). If the code is already taken it tries again, up to 5 times, and then fails.
   2. It inserts the group with `created_by` set to the current user.
   3. It adds the creator as a member through `addGroupMember`. If that fails, it deletes the group, because a group with no members cannot be opened by anyone.
5. The app reloads the groups list, shows a success snackbar and closes the panel.

### 5.3 Join a group with an invite code

**Screen:** the same panel, "Join with a code" section.

1. The user types the code. The field forces capital letters.
2. The `addMemberToGroup(groupCode)` mutation runs.
3. Backend steps:
   1. It looks up the group by code and returns `404` if no group matches.
   2. It returns `400` "User is already a member of the group" if the user has already joined.
   3. It makes sure the `users` row exists ([4.3](#43-fallback-user-sync)).
   4. It inserts the `members` row and returns the group with its updated member list.
4. The app adds the group to the top of the list and closes the panel.

### 5.4 Favorite or unfavorite a group

**Screens:** the star icon on group cards ([favorite_groups.dart](frontend/lib/components/groups/favorite_groups.dart), [user_groups.dart](frontend/lib/components/groups/user_groups.dart))

1. **Optimistic update:** the star changes immediately in local state.
2. The `favoriteGroup(groupId)` mutation runs. The backend deletes the `user_favorites` row if one exists and inserts one if not, then returns the new status.
3. The app applies the status the server returned. If the request failed, it restores the previous status and shows an error.

### 5.5 Open a group

1. Tapping a group calls `setSelectedGroup(group)` and navigates to `/group/balances`.
2. `setSelectedGroup` loads three sets of data in parallel:
   - `groupBalances(groupId)`
   - `expenses(groupId)`
   - `settlements(groupId)`
3. The group header chip ([group_header_card.dart](frontend/lib/components/global/group_header_card.dart)) shows the selected group. Tapping it returns to `/groups`.
4. Pull to refresh on any group screen runs `fetchGroupData`. It reloads the groups list (for member changes) and the three data sets above.

### 5.6 Share the invite code

**Screen:** Balances, [invite_code_card.dart](frontend/lib/components/balances/invite_code_card.dart)

The card shows the group's code. **Copy** puts the code on the clipboard and shows "Invite code copied". The code is shared outside the app, for example by pasting it into a chat.

---

## 6. Expense workflows

**State:** [group_expenses.dart](frontend/lib/providers/groups/group_expenses.dart)
**Backend:** [expenses.service.ts](backend/src/expenses/expenses.service.ts)

### 6.1 View expenses

**Screen:** [expenses/index.dart](frontend/lib/components/expenses/index.dart)

1. The `expenses(groupId)` query requires membership. It returns the group's expenses newest first, with `paid_by` and each split's `user` expanded into full user records.
2. The header shows the number of expenses and their total amount.
3. Each expense card shows the description, the payer, the date and the amount. It also shows your position on that expense, from `Helper.getUserBalance`:
   - "You lent ₱X" if you paid. X is the amount minus your own share.
   - "You owe ₱X" if someone else paid and you have a share.
   - "Not involved" otherwise.
4. Tapping a card expands it to show the split. Only one card is expanded at a time. The split section says "Split equally between N" when every share is the same, and lists each member's share with the payer marked "Paid".

### 6.2 Add an expense

**Screen:** [add_expenses.dart](frontend/lib/components/expenses/add_expenses.dart), opened with **Add expense**. It is a full-screen route.

1. **Details:** the user enters a description and an amount. Amounts allow up to 2 decimal places.
2. **Who paid?:** the user picks the payer. It defaults to the signed-in user, or to the first member if the user is not in the group.
3. **Split type:**
   - **Equal:** the user ticks the members who share the bill. Everyone is ticked by default, including the payer. The amount is divided into whole centavos, and any leftover centavos go to the first members, so the shares always add up to the total. For example, ₱100 split 3 ways is 33.34, 33.33 and 33.33.
   - **Custom amounts:** the user types a share for each ticked member. A pill shows how much is left or over. The form can only be submitted when the shares add up to the amount, within ₱0.01.
4. **Submit** is enabled when the description is not empty, the amount is greater than 0, at least one member is ticked, and (for custom splits) the shares balance.
5. The app builds an `ExpenseInput` with one split per member whose share is greater than 0, rounded to 2 decimal places.
6. The `createExpense(createExpenseInput, splits)` mutation runs. Backend steps:
   1. It checks that the current user is a member of the group.
   2. It inserts the expense. If `paid_by` is empty, it uses the current user as the payer. A member can log an expense that another member paid.
   3. It inserts all the splits in a single statement. If that fails, it deletes the expense, because the two inserts are not in a database transaction.
   4. It fetches the expense again and returns it with its splits.
7. The app adds the expense to the top of the list and reloads that group's balances. It then shows a success snackbar and returns to the Expenses screen.

---

## 7. Balance workflows

**State:** [group_balances.dart](frontend/lib/providers/groups/group_balances.dart) (one provider instance per group id)
**Backend:** [balances.service.ts](backend/src/balances/balances.service.ts), and the SQL functions in [schema.sql](backend/supabase/schema.sql)

### 7.1 Net balance per member

The Postgres function `group_balances(p_group_id)` calculates each member's balance as:

```
balance = (total of expenses they paid)
        − (total of their expense splits)
        + (total of 'paid' settlements they sent)
        − (total of 'paid' settlements they received)
```

Only settlements with the status `paid` change balances. `unpaid`, `pending` and `rejected` settlements have no effect.

- The `groupBalances(groupId)` query calls the function and attaches each member's user record.
- The `totalBalance` query calls `user_total_balance(user_id)`, which adds up the user's balance across all their groups. The app does not use this query yet.
- **Balances screen** ([balances/index.dart](frontend/lib/components/balances/index.dart)):
  - **Net balance card:** your balance, a summary ("You're owed overall", "You owe overall" or "All settled up"), and the chips "Owed to you" and "You owe".
  - **Everyone's balance:** each member's balance.
  - **Favorites carousel:** each card shows your balance in that group.

### 7.2 Suggested payments

**Code:** `getSuggestedPayments` in [balances/index.dart](frontend/lib/components/balances/index.dart). This runs on the device, not the server.

1. For each split on each expense, it records that the split's member owes the payer the split amount. The payer's own split is skipped.
2. For each `paid` settlement from A to B, it records a debt from B to A, which cancels that much of what A owed B.
3. For each pair of members, it subtracts the debts in one direction from the debts in the other, and keeps only the direction that still owes. Amounts under ₱0.01 are dropped.
4. The screen shows the first 3 results.

Each suggestion card:
- **"You pay X":** has a **Settle up** button that goes to `/group/settle`.
- **"X pays you":** has a **Remind** button that sends a reminder ([9.2](#92-send-a-payment-reminder)).
- Any other pair is shown for information only, with no button.

This calculation nets debts per pair. It does not reduce the total number of payments across the group the way a debt-simplification algorithm would.

---

## 8. Settlement workflows

**State:** [group_settlements.dart](frontend/lib/providers/groups/group_settlements.dart) (one provider instance per group id)
**Backend:** [settlements.service.ts](backend/src/settlements/settlements.service.ts)
**Screen:** [settle/index.dart](frontend/lib/components/settle/index.dart)

### 8.1 Settlement lifecycle

```
                 createSettlement            (not used by the app)
                        │
                        ▼
                    [unpaid] ──updateSettlement(status: pending)──┐
                                                                  │
recordPayment ───────────────────────────────────────────────▶ [pending]
(the payer says they paid)                                        │
                                       the receiver confirms ─────┼───▶ [paid]      counts toward balances
                                       the receiver rejects  ─────┴───▶ [rejected]  no effect
```

Rules enforced by the backend:
- Creating or recording a settlement requires the current user to be a member of the group.
- Updating or deleting a settlement requires the current user to be its payer (`from_user`) or receiver (`to_user`).
- Only the receiver can set the status to `paid` or `rejected`.
- Any change to `pending` sends the receiver a "Payment recorded" notification.
- The database rejects settlements where `from_user` equals `to_user`, and settlements with an amount of 0 or less.

### 8.2 Record a payment

**Card:** [record_payment_card.dart](frontend/lib/components/settle/record_payment_card.dart)

1. **From** defaults to the current user. It can be set to any member, so you can record a payment on someone else's behalf.
2. **To** lists only the members the From person still owes money to, using a pairwise debt calculation like the one in 7.2. If that list is empty, the field says "Owes no one".
3. When the From/To pair changes, the amount is filled in with what From owes To. The user can still edit it.
4. **Record payment** calls the `recordPayment` mutation. The backend inserts the settlement with the status `pending` and notifies the receiver ("Payment recorded").
5. The app adds the settlement to the top of the list, clears the amount and closes the keyboard. Balances do not change yet, and the card says so: "Your balance stays at ₱X owed until Y confirms."

### 8.3 Confirm or reject a payment

**Card:** [confirmation_card.dart](frontend/lib/components/settle/confirmation_card.dart). It only appears when you have pending payments to confirm.

1. The card lists settlements where the status is `pending` and you are the receiver, showing at most 3. Each row reads "X says they paid you".
2. **Confirm** sends `updateSettlement` with the status `paid`. **Reject** sends it with the status `rejected`. Both buttons in the row are disabled while the request runs.
3. The app replaces the settlement in its list and reloads the group's balances, because a `paid` settlement changes who owes what.
4. The favorites carousel also shows a count of these pending confirmations for each group.

### 8.4 Settle-up summary and payment history

- **Summary card** ([summary_card.dart](frontend/lib/components/settle/summary_card.dart)): shows the group's total spending, the total of `paid` settlements, and the number of `unpaid` and `pending` settlements. Below that is a "Paid by" bar for each member, ordered by the amount they paid, showing their share and how much they have settled.
- **Payment history** ([payment_history_card.dart](frontend/lib/components/settle/payment_history_card.dart)): lists every settlement in the group, newest first, as "From → To" with the amount, date and a status chip.

---

## 9. Notification workflows

**Backend:** [notifications.service.ts](backend/src/notifications/notifications.service.ts)
**Frontend:** [push.dart](frontend/lib/core/push.dart), [notifications.dart](frontend/lib/providers/global/notifications.dart), [notification/index.dart](frontend/lib/components/notification/index.dart)

### 9.1 Register a device for push notifications

1. When a user signs in, or a restored session is detected, `registerPushToken` asks for notification permission. If the user denies it, the workflow stops.
2. The app gets the FCM token and calls `registerDeviceToken(token)`.
3. Backend steps:
   1. It deletes rows for this token that belong to other users. A device belongs to whoever signed in on it last, so the previous account stops receiving pushes there.
   2. It upserts the `(user_id, token)` row with a new `updated_at`.
4. The app subscribes once to FCM token refreshes. Each new token is registered the same way.
5. On sign out, the token is unregistered and deleted ([3.7](#37-sign-out)).

### 9.2 Send a payment reminder

**Trigger:** the **Remind** button on a suggested payment that is owed to you ([suggested_payment_card.dart](frontend/lib/components/balances/suggested_payment_card.dart)).

1. The `sendReminder({group_id, to_user, amount})` mutation runs. The sender is always the signed-in user. The button is disabled while the request runs.
2. The backend checks that both the sender and the recipient are members of the group.
3. It looks up the sender's name and the group's name, then creates the notification "Payment reminder", with the text "{sender} reminded you to pay ₱X in {group}".
4. The app shows "Reminder sent to {name}".

### 9.3 How a notification is delivered

`NotificationsService.create(from, to, title, description)` is used by both reminders and recorded payments:

1. It inserts a row in `notifications`.
2. It sends the notification to every device token the recipient has, in one FCM multicast call.
3. It deletes tokens that FCM reports as unregistered or invalid, so they are not used again.
4. A failed push is logged as a warning and does not fail the request. The notification is still saved in the database.

On the device, a push that arrives while the app is closed is shown by the system tray. The background handler `firebaseBackgroundHandler` does nothing yet.

**Notifications sent today:**

| Event | Title | Recipient |
|---|---|---|
| A payment is recorded (`recordPayment`, or a status change to `pending`) | Payment recorded | The receiver |
| A reminder is sent | Payment reminder | The member who owes |

### 9.4 View notifications

1. The bell in the group header opens the Notifications screen on the root navigator, so it covers the bottom navigation.
2. The screen runs the `getUserNotifications` query with `networkOnly` every time it opens, and again on pull to refresh. The backend returns the notifications sent to the current user, newest first, with the sender's and recipient's names.
3. Each card shows the sender's avatar with a small icon chosen from the title (expense, reminder, confirmed, or settle), the title, the description, a "From {name}" chip, and a time such as "Today · 2:15 PM".

---

## 10. Profile and account workflows

**Screen:** [settings/index.dart](frontend/lib/components/settings/index.dart)
**State:** [user_profile.dart](frontend/lib/providers/settings/user_profile.dart)
**Backend:** [users.service.ts](backend/src/users/users.service.ts)

### 10.1 Edit profile

1. The screen shows the first name, last name and display name. It takes them from your own member record in your groups, then falls back to Clerk. It also shows the number of groups you are in and the month you joined.
2. **Edit profile** unlocks the fields. **Cancel** restores the saved values.
3. **Save:**
   - The first name is required.
   - If the display name is empty, it is set to "first name last name".
   - The `updateUser` mutation runs. The backend always updates the signed-in user's row and ignores any `id` in the input.
4. The app reloads the groups list so your new name appears on member lists.

The change is saved in Supabase only. Clerk is not updated. A later `user.updated` webhook from Clerk will overwrite these names ([4.1](#41-clerk-webhook-user-created-or-updated)).

### 10.2 Delete account

1. **Delete account** opens a confirmation dialog.
2. The `removeUser` mutation sets `deleted_at` on the user's row. Nothing else is changed.
3. The app then signs the user out ([3.7](#37-sign-out)).

The Clerk account is not deleted, so the user can sign in again. Full anonymisation only happens if the user is deleted in Clerk ([4.2](#42-clerk-webhook-user-deleted)).

---

## 11. Data refresh rules

| Data | Loaded when | Refreshed after |
|---|---|---|
| User's groups | The main navigation first renders; pull to refresh on Groups | Creating a group (full reload); joining a group (added locally); saving the profile (provider reset); any group-screen pull to refresh |
| Group balances | Opening a group; the favorites carousel | Adding an expense; confirming or rejecting a settlement; pull to refresh |
| Group expenses | Opening a group | Adding an expense (added locally); pull to refresh |
| Group settlements | Opening a group; the favorites carousel | Recording a payment (added locally); a status change (replaced locally); pull to refresh |
| Notifications | The main navigation first renders; opening the Notifications screen | Pull to refresh |

Every list query uses the `networkOnly` fetch policy, so the app never shows stale cached results. Group-scoped providers stay alive for the whole session, and balances and settlements have one instance per group id, so several groups can be loaded at once.

---

## 12. Error handling

- **Backend:** services rethrow Supabase and Postgres errors unchanged, and use Nest exceptions for logic errors (`NotFound`, `Forbidden`, `BadRequest`, `InternalServerError`). `ValidationPipe` is global.
- **Frontend:** every provider method is wrapped in `Helper.guard`, which turns thrown errors into `ResponseStatus(status: false)`. `Helper.error` extracts the GraphQL or link error message. `Helper.showErrorSnackBar` maps raw messages to friendly ones:
  - Network problems → "Network error. Please check your connection and try again."
  - Duplicate key or already a member → "This entry already exists."
  - Constraint or validation failures → "Could not add / save / delete this", depending on the action.
  - Anything else → "Something went wrong."
- **Clerk errors** appear as snackbars through `ClerkErrorListener`. They are not shown a second time.

---

## 13. Backend operations not used by the app

These GraphQL operations exist and are guarded, but no screen calls them yet:

| Operation | Behavior |
|---|---|
| `updateGroup`, `removeGroup` | Creator only (`assertCreator`) |
| `removeMemberFromGroup` | Any member can remove themselves. Only the creator can remove other members. |
| `groupMembers` | Members only |
| `favoriteGroups` | The user's favorite groups that they are still a member of |
| `expense(id)`, `updateExpense`, `removeExpense` | Members of the expense's group. `updateExpense` does not change the splits. |
| `createSettlement` | Creates an `unpaid` settlement. The provider has a `createSettlement` method, but no screen uses it. |
| `removeSettlement` | The payer or the receiver |
| `totalBalance` | The user's balance across all groups |
| `userFavorites` CRUD (`createUserFavorite`, `userFavorites`, …) | Duplicates `favoriteGroup` |
| `user` | The signed-in user's row |
