-- up
create table session (
  id integer primary key,
  user_id integer not null,
  token text not null,
  created_at integer not null default(strftime('%s', 'now')),
  foreign key(user_id) references user(id),
  UNIQUE(user_id),
  UNIQUE(token)
) strict

-- down
drop table session
