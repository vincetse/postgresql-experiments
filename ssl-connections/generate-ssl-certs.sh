#!/bin/sh
# https://www.postgresql.org/docs/current/ssl-tcp.html
set -euxo pipefail

apk --no-cache add openssl
cd /data/ssl/certs

function create_csr_and_key_file()
{
  local domain=$1
  local csr=$2
  local key=$3
  openssl req -new -nodes -text -out "${csr}" \
    -keyout "${key}" -subj "/CN=${domain}"
  chmod og-rwx "${key}"
}

function create_root_ca()
{
  local root_csr=$1
  local root_key=$2
  local root_cert=$3
  openssl x509 -req -in "${root_csr}" -text -days 1 \
    -extensions v3_ca \
    -signkey "${root_key}" -out "${root_cert}"
}

function create_signed_cert()
{
  local csr=$1
  local root_crt=$2
  local root_key=$3
  local signed_cert=$4
  openssl x509 -req -in "${csr}" -text -days 1 \
    -CA "${root_crt}" -CAkey "${root_key}" -CAcreateserial \
    -out "${signed_cert}"
}

DOMAIN=mypg.io
ROOT_CSR=root.csr
ROOT_KEY=root.key
ROOT_CERT=root.crt
DB_CSR=server.csr
DB_KEY=server.key
DB_CERT=server.crt

create_csr_and_key_file "root.${DOMAIN}" "${ROOT_CSR}" "${ROOT_KEY}"
create_root_ca "${ROOT_CSR}" "${ROOT_KEY}" "${ROOT_CERT}"
create_csr_and_key_file "db.${DOMAIN}" "${DB_CSR}" "${DB_KEY}"
create_signed_cert "${DB_CSR}" "${ROOT_CERT}" "${ROOT_KEY}" "${DB_CERT}"

# https://gist.github.com/mrw34/c97bb03ea1054afb551886ffc8b63c3b
chown 70:70 ${DB_KEY} ${DB_CSR} ${DB_CERT}
