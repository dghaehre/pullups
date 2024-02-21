-- up
alter table user add column username text;
alter table user add column password text;


-- TODO: add unique constraint to username
-- have to create a tmp table and copy shit if I want to keep data

-- down
alter table user drop column username;
alter table user drop column password
