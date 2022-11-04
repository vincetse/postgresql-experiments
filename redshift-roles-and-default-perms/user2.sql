--------------------------------------------------------------------------------
-- user2 can also read table with default perms
--------------------------------------------------------------------------------
SELECT COUNT(*) FROM shared.table_with_default_perms;
INSERT INTO shared.table_with_default_perms(id) VALUES(1);

--------------------------------------------------------------------------------
-- read a table created by user1 in a schema that has default perms
--------------------------------------------------------------------------------
SELECT COUNT(*) FROM shared.table_created_by_user1;

--------------------------------------------------------------------------------
-- Who does the system see this user as?
--------------------------------------------------------------------------------
SELECT SESSION_USER, CURRENT_USER;
\x
SELECT * FROM pg_stat_activity WHERE usename = 'user2';
