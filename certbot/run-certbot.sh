#!/bin/bash
# Obtain or renew the certificate for $CN, then copy it to /var/certs for nginx.
#
# /etc/letsencrypt must be a persistent volume (see docker-compose.yml) so the
# account and certificate lineage survive container rebuilds. With
# --keep-until-expiring an existing, not-yet-due certificate is reused instead
# of requesting a new one every time the container starts.
set -euo pipefail

letsencrypt certonly --webroot -w /var/www/letsencrypt -d "$CN" --cert-name "$CN" \
    --agree-tos --email "$EMAIL" --non-interactive --text --keep-until-expiring

# live/ always points at the newest files of the lineage; archive/ numbers them
# cert1.pem, cert2.pem, ... per renewal. -L copies the files, not the symlinks.
# Output names stay the same so nginx's ssl_certificate paths need no change.
LIVE=/etc/letsencrypt/live/"$CN"
cp -L "$LIVE"/cert.pem /var/certs/"$CN"-cert1.pem
cp -L "$LIVE"/chain.pem /var/certs/chain1.pem
cp -L "$LIVE"/fullchain.pem /var/certs/fullchain1.pem
cp -L "$LIVE"/privkey.pem /var/certs/"$CN"-privkey1.pem
