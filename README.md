# new-phpstan-rule

A Claude Code skill that creates a custom PHPStan rule as its own Composer package, test-first, and optionally publishes it to GitHub and Packagist.

## Why

A convention that's only written down gets broken; a PHPStan rule enforces it in every project that installs it. Making each rule its own package lets a project install just the rules it wants, and version them separately. The cost is the same setup every time, which this skill makes deterministic.

## What it does

`/ianf-new-phpstan-rule <what the rule should report>`:

1. Settles a package name with you. It's permanent once on Packagist.
2. Probes PHPStan's actual behaviour before encoding any assumption about it.
3. Scaffolds the package with `scripts/scaffold.sh` from `template/`: Composer, PHPUnit, PHPStan, Pint and CI config, licence and README.
4. Writes behaviour-named `RuleTestCase` tests with one fixture each and sees them fail.
5. Writes the rule, then runs `scripts/check.sh` until everything passes, plus a mutation check.
6. Commits and tags `v0.1.0`.
7. If you asked, publishes with the `github` and `packagist` commands from [repo-tools](https://github.com/ianflanagan1/repo-tools), found on your PATH.
8. Offers to require the package in the project that needed it.

Each package is created in `~/projects/phpstan-rules/<name>/` as an independent git repo. Set `PHPSTAN_RULES_DIR` to use another directory.

| | Example |
|---|---|
| Directory | `inferable-var-tag-name` |
| Package and GitHub repo | `ianflanagan1/phpstan-inferable-var-tag-name` |
| Namespace | `IanFlanagan\PhpstanRules\InferableVarTagName` |
| Rule class | `InferableVarTagNameRule` |

## Setup

1. Docker must be running: Composer and the checks run in the `composer` image, so you don't need PHP installed.
2. Link the skill into Claude Code:

   ```sh
   ln -s ~/projects/claude/new-phpstan-rule/skills/ianf-new-phpstan-rule ~/.claude/skills/ianf-new-phpstan-rule
   ```

3. To publish, set up [repo-tools](https://github.com/ianflanagan1/repo-tools#setup) by following its README: `github` and `packagist` on your PATH, the GitHub token and the Packagist tokens.
4. Optionally allow the scripts in `~/.claude/settings.json`:

   ```json
   "Bash(~/.claude/skills/ianf-new-phpstan-rule/scripts/scaffold.sh *)",
   "Bash(~/.claude/skills/ianf-new-phpstan-rule/scripts/check.sh *)"
   ```

To change the vendor, namespace or author, edit the variables at the top of `scripts/scaffold.sh` and the author in `template/composer.json` and `template/LICENSE`.

## The scripts

```sh
scripts/scaffold.sh <name> "<description>"   # new package from the template
scripts/check.sh <package-dir>               # placeholders, composer validate, PHPUnit, PHPStan, Pint
```

Template dotfiles are stored as `_gitignore`, `_gitattributes` and `_github/`, so they don't act on this repo; `scaffold.sh` renames them.

## Development

```sh
devbox run lint   # shellcheck
```

## License

MIT
