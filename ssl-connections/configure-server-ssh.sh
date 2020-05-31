#!/bin/bash
set -euxo pipefail
SSL_CERT_DIR=/data/ssl/certs

echo "
ssl = on
ssl_ca_file = '${SSL_CERT_DIR}/root.crt'
ssl_cert_file = '${SSL_CERT_DIR}/server.crt'
ssl_key_file = '${SSL_CERT_DIR}/server.key'
ssl_prefer_server_ciphers = on
ssl_ciphers = 'HIGH:MEDIUM:+3DES:!aNULL'
" >> "${PGDATA}/postgresql.conf"

sed -i -e 's/^host all all all/hostssl all all all/' "${PGDATA}/pg_hba.conf"
