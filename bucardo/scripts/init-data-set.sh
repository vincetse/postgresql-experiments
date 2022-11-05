#!/bin/bash
set -euxo pipefail
function initialize()
{
  local host=$1
  until pg_isready --host=$host; do
    sleep 1;
  done
  pgbench --initialize --foreign-keys --host=$host
  psql --host=$host --command='alter table pgbench_history add column hid serial primary key;'
}
initialize leader
initialize follower1
initialize follower2
