# Default Permissions for Shared Schema

PostgreSQL table access can become hairy when users create tables using their
own logins, but need to share the tables with other users.  The workaround
usually involves users figuring out how to grant access to their tables, or
making everyone superusers in an attempt to circumvent the permission model.

In order to avoid such permission hell, a shared schema with the appropriate
default permissions and users with the appropriate role permissions will
ensure that tables are created with the right ownership for sharing.

## Shared Schema

```sql
-- create a new shared schema
CREATE SCHEMA shared;

-- create the team
CREATE ROLE team;

-- create users to be added to the team
CREATE ROLE user1 PASSWORD 'postgres' LOGIN IN ROLE team;
CREATE ROLE user2 PASSWORD 'postgres' LOGIN IN ROLE team;

-- SET ROLE so that it objects are created as the team role.
-- INHERIT in the CREATE ROLE does not have the same effect.
ALTER ROLE user1 SET ROLE team;
ALTER ROLE user2 SET ROLE team;

-- set up default perms for shared schema so that users can read it.
GRANT ALL PRIVILEGES ON SCHEMA shared TO team;

-- set default permissions on the schema to that all users in the team
-- can read the tables in the schema.
ALTER DEFAULT PRIVILEGES
  FOR ROLE team
  IN SCHEMA shared
GRANT
  ALL PRIVILEGES
ON TABLES
  TO team
;
```

## Demo

```shell
# Remember that the first run will not work correctly like the rest
# this repo.
docker-compose up
```
