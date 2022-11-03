-- set default perms in a schema so that a group of users all have similar
-- permissions regardless of who created objects.

DROP SCHEMA IF EXISTS shared CASCADE;
CREATE SCHEMA shared;

DROP ROLE IF EXISTS user1;
DROP ROLE IF EXISTS user2;

DROP ROLE IF EXISTS team;
CREATE ROLE team;

CREATE ROLE user1 PASSWORD 'postgres' LOGIN IN ROLE team;
CREATE ROLE user2 PASSWORD 'postgres' LOGIN IN ROLE team;

-- SET ROLE so that it objects are created as the team role.
-- INHERIT in the CREATE ROLE does not have the same effect.
ALTER ROLE user1 SET ROLE team;
ALTER ROLE user2 SET ROLE team;

--------------------------------------------------------------------------------
-- table in public schema which doesn't have default perms
-- for sharing table between users.
--------------------------------------------------------------------------------
DROP TABLE IF EXISTS no_default_perms;
CREATE TABLE no_default_perms(id INTEGER);

--------------------------------------------------------------------------------
-- set up default perms for shared schema so that users can read it.
--------------------------------------------------------------------------------
GRANT ALL PRIVILEGES ON SCHEMA shared TO team;

-- this statement only affects the user running it
ALTER DEFAULT PRIVILEGES
  IN SCHEMA shared
GRANT
  ALL PRIVILEGES
ON TABLES
  TO team
;

-- this statement sets default privileges for everyone in the group
ALTER DEFAULT PRIVILEGES
  FOR ROLE team
  IN SCHEMA shared
GRANT
  ALL PRIVILEGES
ON TABLES
  TO team
;

--------------------------------------------------------------------------------
-- create a table in shared schema and watch user1 and user2 be able to use it
--------------------------------------------------------------------------------
CREATE TABLE shared.table_with_default_perms(id INTEGER);
