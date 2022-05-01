CREATE TABLE schema_migrations (version text primary key)
CREATE TABLE contest (
  id integer primary key,
  name text unique not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)