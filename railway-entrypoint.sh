#!/bin/sh
# FMD Server on Railway: bind the injected PORT, require a registration token, own the volume, drop privileges.
set -eu

die() { echo "fmd-server-railway: $*" >&2; exit 1; }

: "${FMD_REGISTRATIONTOKEN:?FMD_REGISTRATIONTOKEN is empty - registration would be open to anyone}"
[ "${#FMD_REGISTRATIONTOKEN}" -ge 16 ] || die "FMD_REGISTRATIONTOKEN must be at least 16 characters"

PORT="${PORT:-8080}"
DATA=/var/lib/fmd-server/db
export FMD_PORTINSECURE="$PORT"
# TLS is terminated by Railway's edge, so the server's own TLS listener stays off
export FMD_PORTSECURE=""
export FMD_DATABASEDIR="$DATA"
export FMD_LOGLEVEL="${FMD_LOGLEVEL:-info}"

mkdir -p "$DATA"
echo "fmd-server-railway: data dir owner before chown=$(stat -c %u:%g "$DATA") port=$PORT"
chown -R 1000:65533 "$DATA"
chmod 770 "$DATA"
echo "fmd-server-railway: data dir owner after chown=$(stat -c %u:%g "$DATA")"

# su-exec drops to the upstream service user (uid 1000, gid 65533) and execs the upstream command line
exec su-exec 1000:65533 /opt/fmd-server serve --db-dir "$DATA"
