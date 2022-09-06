-- up
create table mapping (
  id integer primary key,
  user_id integer not null,
  contest_id integer not null,
  foreign key(user_id) references user(id),
  foreign key(contest_id) references contest(id),
  UNIQUE (user_id, contest_id)
)

-- down
drop table recording
