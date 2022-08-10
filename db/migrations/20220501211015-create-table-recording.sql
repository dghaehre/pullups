-- up
create table recording (
  id integer primary key,
  amount int not null default 0,
  user_id integer not null,
  contest_id integer not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer,
  year_day integer not null,
  year integer not null,
  foreign key(user_id) references user(id),
  foreign key(contest_id) references contest(id),
  UNIQUE (user_id, year, year_day)
)

-- down
drop table recording
