-- up
create table user (
  id integer primary key,
  name text not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)

-- down
drop table user
