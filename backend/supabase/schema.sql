create table users (
  id          text primary key,
  email       text unique,
  display_name text,
  first_name  text,
  last_name   text,
  image_url   text,
  created_at  timestamptz default now(),
  deleted_at  timestamptz                    -- set when anonymised after Clerk deletion
);

create table groups (
  id          bigint generated always as identity primary key,
  code        text not null unique,
  name        text not null,
  description text not null,
  avatar_color text not null default '#984063',
  created_by  text not null,                 -- Clerk user id
  created_at  timestamptz not null default now()
);

create table members (
  id         bigint generated always as identity primary key,
  group_id   bigint not null references groups(id) on delete cascade,
  user_id    text not null references users(id) on delete cascade,
  joined_at  timestamptz not null default now(),
  unique (group_id, user_id)
);

create table expenses (
  id           bigint generated always as identity primary key,
  group_id     bigint not null references groups(id) on delete cascade,
  description  text not null,
  amount       numeric(12, 2) not null check (amount > 0),
  paid_by      text not null references users(id),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz
);

-- who owes what for each expense
create table expense_splits (
  id          bigint generated always as identity primary key,
  expense_id  bigint not null references expenses(id) on delete cascade,
  user_id     text not null references users(id),
  amount      numeric(12, 2) not null check (amount >= 0),
  unique (expense_id, user_id)
);

-- a payment between two members that pays down their balance; not tied to any expense
create table settlements (
  id          bigint generated always as identity primary key,
  group_id    bigint not null references groups(id) on delete cascade,
  from_user   text not null references users(id),
  to_user     text not null references users(id),
  amount      numeric(12, 2) not null check (amount > 0),
  status      text not null default 'unpaid' check (status in ('unpaid', 'pending', 'paid', 'rejected')),
  created_at  timestamptz not null default now(),
  check (from_user <> to_user)
);

create table device_tokens (
  id          bigint generated always as identity primary key,
  user_id     text not null,
  token       text not null,
  updated_at  timestamptz not null default now(),
  unique (user_id, token)
);

create table user_favorites (
  id          bigint generated always as identity primary key,
  user_id     text not null references users(id) on delete cascade,
  group_id    bigint not null references groups(id) on delete cascade,
  created_at  timestamptz not null default now(),
  unique (user_id, group_id)
);

create table notifications (
  id          bigint generated always as identity primary key,
  from_user   text not null references users(id),   -- who triggered it
  to_user     text not null references users(id),   -- who receives it
  title       text not null,
  description text not null,
  created_at  timestamptz not null default now()
);


create index on members (user_id);
create index on expenses (group_id);
create index on expense_splits (expense_id);
create index on settlements (group_id);

-- each member's balance in a group: positive = the group owes them, negative = they owe the group
-- paid for expenses - their share of expenses + paid settlements they sent - paid settlements they received
create or replace function group_balances(p_group_id bigint)
returns table (user_id text, balance numeric)
language sql stable
as $$
  select
    m.user_id,
    coalesce((select sum(e.amount) from expenses e
              where e.group_id = p_group_id and e.paid_by = m.user_id), 0)
    - coalesce((select sum(s.amount) from expense_splits s join expenses e on e.id = s.expense_id
                where e.group_id = p_group_id and s.user_id = m.user_id), 0)
    + coalesce((select sum(st.amount) from settlements st
                where st.group_id = p_group_id and st.status = 'paid' and st.from_user = m.user_id), 0)
    - coalesce((select sum(st.amount) from settlements st
                where st.group_id = p_group_id and st.status = 'paid' and st.to_user = m.user_id), 0)
  from members m
  where m.group_id = p_group_id;
$$;

-- a user's balance summed across every group they're in
create or replace function user_total_balance(p_user_id text)
returns numeric
language sql stable
as $$
  select coalesce(sum(b.balance), 0)
  from members m
  cross join lateral group_balances(m.group_id) b
  where m.user_id = p_user_id and b.user_id = p_user_id;
$$;

alter table groups         enable row level security;
alter table members        enable row level security;
alter table expenses       enable row level security;
alter table expense_splits enable row level security;
alter table settlements    enable row level security;
alter table device_tokens  enable row level security;
alter table users          enable row level security;
alter table user_favorites  enable row level security;
alter table notifications  enable row level security;