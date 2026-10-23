#!/usr/bin/env bash
#
# Creates a new PHPStan rule package from the template next to this script, as its own git
# repo, and installs its dev dependencies. It doesn't write the rule or its tests, commit or
# publish.
#
# Usage: scaffold.sh <name> <description>
#
#   name         kebab-case, e.g. inferable-var-tag-name. Becomes the directory <name>, the
#                package ianflanagan1/phpstan-<name>, the namespace
#                IanFlanagan\PhpstanRules\<PascalName> and the rule class <PascalName>Rule.
#   description  one sentence for composer.json and the README
#
# The package is created in $PHPSTAN_RULES_DIR (default ~/projects/phpstan-rules). The
# script stops if the directory exists or the package name is taken on Packagist.
# Composer runs in the composer Docker image, so Docker must be running.

set -euo pipefail

VENDOR=ianflanagan1
NAMESPACE_ROOT='IanFlanagan\PhpstanRules'
BASE_DIR=${PHPSTAN_RULES_DIR:-$HOME/projects/phpstan-rules}

die() {
    echo "scaffold: $*" >&2
    exit 1
}

[ $# -eq 2 ] || die "usage: scaffold.sh <name> <description>"
name=$1
description=$2
[[ $name =~ ^[a-z][a-z0-9]*(-[a-z0-9]+)*$ ]] || die "name must be kebab-case, not '$name'"
[ -n "$description" ] || die "description is empty"

template=$(cd "$(dirname "$0")/../template" && pwd -P)
dir="$BASE_DIR/$name"
package="$VENDOR/phpstan-$name"
pascal=$(perl -pe 's/(?:^|-)(.)/\U$1/g' <<<"$name")
namespace="$NAMESPACE_ROOT\\$pascal"

[ ! -e "$dir" ] || die "$dir already exists"
if curl -fsS -o /dev/null "https://packagist.org/packages/$package.json" 2>/dev/null; then
    die "$package is already on Packagist"
fi
docker info >/dev/null 2>&1 || die "Docker isn't running"

mkdir -p "$BASE_DIR"
cp -R "$template" "$dir"
cd "$dir"

# Template dotfiles are stored with a _ prefix so they don't act on the skill's own repo
for entry in _*; do
    mv "$entry" ".${entry#_}"
done

mkdir -p src tests/data

NAME=$name PASCAL=$pascal PACKAGE=$package NAMESPACE=$namespace DESCRIPTION=$description YEAR=$(date +%Y) \
    find . -type f -not -path './.git/*' -exec perl -pi -e '
        s/__NAMESPACE_JSON__/$ENV{NAMESPACE} =~ s{\\}{\\\\}gr/ge;
        s/__NAMESPACE__/$ENV{NAMESPACE}/g;
        s/__PASCAL__/$ENV{PASCAL}/g;
        s/__PACKAGE__/$ENV{PACKAGE}/g;
        s/__NAME__/$ENV{NAME}/g;
        s/__DESCRIPTION__/$ENV{DESCRIPTION}/g;
        s/__YEAR__/$ENV{YEAR}/g;
    ' {} +

git init -q -b main

docker run --rm -u "$(id -u):$(id -g)" -e COMPOSER_HOME=/tmp/composer \
    -e GIT_CONFIG_COUNT=1 -e GIT_CONFIG_KEY_0=safe.directory -e GIT_CONFIG_VALUE_0=/app \
    -v "$dir":/app -w /app composer:latest \
    composer update --no-interaction --no-progress \
    || die "composer failed; Docker must be able to mount $dir (Docker Desktop shares /Users by default)"

cat <<EOF
Created $dir
  package    $package
  namespace  $namespace
  rule       src/${pascal}Rule.php (to write)
  test       tests/${pascal}RuleTest.php (to write), fixtures in tests/data/
  README     fill __WHAT_IT_REPORTS__ and __IDENTIFIER__
EOF
