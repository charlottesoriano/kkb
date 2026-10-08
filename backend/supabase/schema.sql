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
  created_at   timestamptz not null default now()
  updated_at   timestamptz
);

-- who owes what for each expense
create table expense_splits (
  id          bigint generated always as identity primary key,
  expense_id  bigint not null references expenses(id) on delete cascade,
  user_id     text not null,
  amount      numeric(12, 2) not null check (amount >= 0),
  unique (expense_id, user_id)
);

create table settlements (
  id          bigint generated always as identity primary key,
  group_id    bigint not null references groups(id) on delete cascade,
  from_user   text not null,
  to_user     text not null,
  amount      numeric(12, 2) not null check (amount > 0),
  status      text not null default 'pending' check (status in ('pending', 'paid', 'rejected')),
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


create index on members (user_id);
create index on expenses (group_id);
create index on expense_splits (expense_id);
create index on settlements (group_id);

alter table groups         enable row level security;
alter table members        enable row level security;
alter table expenses       enable row level security;
alter table expense_splits enable row level security;
alter table settlements    enable row level security;
alter table device_tokens  enable row level security;
alter table users          enable row level security;
alter table user_favorites  enable row level security;