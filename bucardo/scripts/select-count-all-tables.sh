#!/bin/bash
set -euo pipefail

function get_summary()
{
  local host=$1
  psql --host="${host}" --command='\conninfo'
  psql --host="${host}" --command="
    SELECT
      'pgbench_branches' AS table_name,
      (SELECT count(*) FROM pgbench_branches) AS count
    UNION ALL
    SELECT
      'pgbench_tellers' AS table_name,
      (SELECT count(*) FROM pgbench_tellers) AS count
    UNION ALL
    SELECT
      'pgbench_accounts' AS table_name,
      (SELECT count(*) FROM pgbench_accounts) AS count
    UNION ALL
    SELECT
      'pgbench_history' AS table_name,
      (SELECT count(*) FROM pgbench_history) AS count
    ;
  "
}

for host in leader follower1 follower2; do
  get_summary "${host}"
done
