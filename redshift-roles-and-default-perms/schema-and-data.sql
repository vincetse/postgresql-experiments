-- set default perms in a schema so that a group of users all have similar
-- permissions regardless of who created objects.

DROP SCHEMA IF EXISTS shared CASCADE;
CREATE SCHEMA shared;

DROP USER IF EXISTS user1;
DROP USER IF EXISTS user2;

DROP ROLE team FORCE;
CREATE ROLE team;

CREATE USER user1 PASSWORD 'p0sTgres';
CREATE USER user2 PASSWORD 'p0sTgres';

GRANT ROLE team TO user1;
GRANT ROLE team TO user2;

--------------------------------------------------------------------------------
-- table in public schema which doesn't have default perms
-- for sharing table between users.
--------------------------------------------------------------------------------
DROP TABLE IF EXISTS no_default_perms;
CREATE TABLE no_default_perms(id INTEGER);

--------------------------------------------------------------------------------
-- set up default perms for shared schema so that users can read it.
--------------------------------------------------------------------------------
GRANT ALL PRIVILEGES ON SCHEMA shared TO ROLE team;

-- this statement only affects the user running it
ALTER DEFAULT PRIVILEGES
  IN SCHEMA shared
GRANT
  ALL PRIVILEGES
ON TABLES
  TO ROLE team
;

-- this statement sets default privileges for everyone in the group
ALTER DEFAULT PRIVILEGES
  FOR USER user1
  IN SCHEMA shared
GRANT
  ALL PRIVILEGES
ON TABLES
  TO ROLE team
;

ALTER DEFAULT PRIVILEGES
  FOR USER user2
  IN SCHEMA shared
GRANT
  ALL PRIVILEGES
ON TABLES
  TO ROLE team
;


--------------------------------------------------------------------------------
-- create a table in shared schema and watch user1 and user2 be able to use it
--------------------------------------------------------------------------------
CREATE TABLE shared.table_with_default_perms(id INTEGER);
