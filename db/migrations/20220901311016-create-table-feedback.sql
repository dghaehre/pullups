-- up
create table feedback (
  id integer primary key,
  message text not null,
  contest_id integer,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)

-- down
drop table feedback
