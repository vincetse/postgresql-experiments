# Bucardo Replication

Postgresql replication with [Bucardo](https://bucardo.org/Bucardo/).

## Instructions

THe following should be run in 3 separate terminals so that you can see progress of each one.  There is one "leader" database that `pgbench` will write to, and 2 "follower" databases that are replicated to by Bucardo.

**First Terminal**
In the first terminal, Kick off the Postgresql containers, load data to them with pgbench, and kick off Bucardo to start the replication.

```
make up
```

You will see data database get initialized with `pgbench` data, and Bucardo coming up.


**Second Terminal**
One Bucardo is done initializing, we can start a second window to query the 4 tables in each database to spy on the replication progress.

```
# get a shell
make client

# query the table counts for each database
watch -n 1 /scripts/select-count-all-tables.sh
```

**Third Terminal**
Now you are ready to kick off `pgbench` to generate some data.  You will see the number of records changing in the `pgbench_history` table in the second terminal.

```
make pgbench
```
