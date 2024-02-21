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
, username text, password text)
CREATE TABLE recording (
  id integer primary key,
  amount int not null default 0,
  user_id integer not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer,
  year_day integer not null,
  year integer not null,
  foreign key(user_id) references user(id),
  UNIQUE (user_id, year, year_day)
)
CREATE TABLE mapping (
  id integer primary key,
  user_id integer not null,
  contest_id integer not null,
  foreign key(user_id) references user(id),
  foreign key(contest_id) references contest(id),
  UNIQUE (user_id, contest_id)
)
CREATE TABLE feedback (
  id integer primary key,
  message text not null,
  contest_id integer,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)
CREATE TABLE session (
  id integer primary key,
  user_id integer not null,
  token text not null,
  created_at integer not null default(strftime('%s', 'now')),
  foreign key(user_id) references user(id),
  UNIQUE(user_id),
  UNIQUE(token)
) strict
