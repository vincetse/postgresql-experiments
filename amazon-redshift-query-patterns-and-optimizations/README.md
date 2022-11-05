# Default Permissions for Shared Schema in Amazon Redshift

Redshift was forked from PostgreSQL around version 8, so their permission model
has diverged as each add new features.  After working out the
[PostgresSQL shared schema](../roles-and-default-perms), we move on to do the
same in Redshift.  Unfortunately, Redshift objects can only be owned by one
user, and not groups nor roles, so we are only able to get as far as allowing
shared CRUD operations on a table, but not dropping or updating of the tables
themselves since they have to be owned by one user.
