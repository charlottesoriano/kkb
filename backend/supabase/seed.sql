insert into users (id, email, display_name, first_name, last_name) values
  ('user_123', 'alice@example.com', 'Alice Cruz', 'Alice', 'Cruz'),
  ('user_456', 'bob@example.com', 'Bob Reyes', 'Bob', 'Reyes');

insert into groups (name, description, created_by) values ('Boracay Trip', 'A trip to Boracay', 'user_123');

insert into members (group_id, user_id) values
  (1, 'user_123'),
  (1, 'user_456');

insert into expenses (group_id, description, amount, paid_by)
values (1, 'Dinner', 1200.00, 'user_123');

insert into expense_splits (expense_id, user_id, amount) values
  (1, 'user_123', 600.00),
  (1, 'user_456', 600.00);