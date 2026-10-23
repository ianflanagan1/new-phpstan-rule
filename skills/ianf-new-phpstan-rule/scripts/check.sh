#!/usr/bin/env bash
#
# Runs every check a PHPStan rule package must pass before it's committed or published:
# no unfilled template placeholders, a valid composer.json, PHPUnit, PHPStan and Pint.
#
# Usage: check.sh <package-dir>
#
# Composer and the tools run in the composer Docker image, so Docker must be running.
# Exits 0 when every check passes, 1 otherwise.

set -euo pipefail

die() {
    echo "check: $*" >&2
    exit 1
}

[ $# -eq 1 ] || die "usage: check.sh <package-dir>"
dir=$(cd "$1" 2>/dev/null && pwd) || die "no such directory: $1"

if placeholders=$(grep -rnE '__(NAME|PASCAL|PACKAGE|NAMESPACE|NAMESPACE_JSON|DESCRIPTION|YEAR|WHAT_IT_REPORTS|IDENTIFIER)__' "$dir" --exclude-dir=vendor --exclude-dir=.git); then
    echo "$placeholders" >&2
    die "unfilled template placeholders"
fi

run() {
    docker run --rm -u "$(id -u):$(id -g)" -e COMPOSER_HOME=/tmp/composer \
        -e GIT_CONFIG_COUNT=1 -e GIT_CONFIG_KEY_0=safe.directory -e GIT_CONFIG_VALUE_0=/app \
        -v "$dir":/app -w /app composer:latest "$@"
}

status=0
run composer validate --strict --no-check-version --quiet || { echo "check: composer.json is invalid" >&2; status=1; }
run vendor/bin/phpunit --colors=never || status=1
run vendor/bin/phpstan analyse --no-progress || status=1
run vendor/bin/pint --test || status=1

[ $status -eq 0 ] && echo "check: all passed"
exit $status
