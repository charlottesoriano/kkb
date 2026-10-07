insert into groups (name, created_by) values ('Boracay Trip', 'user_AAA');

insert into members (group_id, user_id) values
  (1, 'user_AAA'),
  (1, 'user_BBB');

insert into expenses (group_id, description, amount, paid_by)
values (1, 'Dinner', 1200.00, 'user_AAA');

insert into expense_splits (expense_id, user_id, amount) values
  (1, 'user_AAA', 600.00),
  (1, 'user_BBB', 600.00);