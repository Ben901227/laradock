#!/bin/sh
# Build the self-hosted php-fpm base image for a pinned PHP patch release.
#
# Usage: php-fpm/base/build.sh 8.4.27
#
# Produces ncumt/php-fpm:<version>-<major.minor>, e.g. ncumt/php-fpm:8.4.27-8.4.
# Then set in .env:
#   PHP_FPM_BASE_IMAGE=ncumt/php-fpm
#   PHP_FPM_BASE_IMAGE_TAG_PREFIX=<version>
# and run `docker-compose build php-fpm`.
set -eu

VERSION=${1:?usage: $0 <php-version, e.g. 8.4.27>}
MINOR=$(echo "$VERSION" | cut -d. -f1,2)
DEBIAN=${DEBIAN_SUITE:-trixie}
DIR=$(cd "$(dirname "$0")" && pwd)

docker build --pull \
    -f "$DIR/Dockerfile-$MINOR" \
    --build-arg "PHP_IMAGE_TAG=$VERSION-fpm-$DEBIAN" \
    -t "ncumt/php-fpm:$VERSION-$MINOR" \
    "$DIR"

docker run --rm --entrypoint php "ncumt/php-fpm:$VERSION-$MINOR" -r 'echo PHP_VERSION, PHP_EOL;'
