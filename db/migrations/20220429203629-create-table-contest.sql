-- up
create table contest (
  id integer primary key,
  name text unique not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)

-- down
drop table contest