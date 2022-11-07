--------------------------------------------------------------------------------
-- should not be able to read public.no_default_perms table
--------------------------------------------------------------------------------
SELECT COUNT(*) FROM no_default_perms;

--------------------------------------------------------------------------------
-- user1 will be able to read shared.table_with_default_perms since
-- the schema has default perms
--------------------------------------------------------------------------------
SELECT COUNT(*) FROM shared.table_with_default_perms;
INSERT INTO shared.table_with_default_perms(id) VALUES(1);

--------------------------------------------------------------------------------
-- user2 will be able to read at able created by user1
--------------------------------------------------------------------------------
CREATE TABLE shared.table_created_by_user1(id INTEGER);
SELECT COUNT(*) FROM shared.table_created_by_user1;

--------------------------------------------------------------------------------
-- Who does the system see this user as?
--------------------------------------------------------------------------------
SELECT SESSION_USER, CURRENT_USER;
\x
SELECT * FROM pg_stat_activity WHERE usename = 'user1';
