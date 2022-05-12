-- up
create table recording (
  id integer primary key,
  amount int not null default 0,
  user_id integer not null,
  contest_id integer not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer,
  foreign key(user_id) references user(id),
  foreign key(contest_id) references contest(id) 
)

-- down
drop table recording
