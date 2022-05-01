CREATE TABLE schema_migrations (version text primary key)
CREATE TABLE contest (
  id integer primary key,
  name text unique not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)
CREATE TABLE user (
  id integer primary key,
  name text not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)
CREATE TABLE recording (
  id integer primary key,
  amount int not null,
  user_id integer not null,
  contest_id integer not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer,
  foreign key(user_id) references user(id),
  foreign key(contest_id) references contest(id) 
)