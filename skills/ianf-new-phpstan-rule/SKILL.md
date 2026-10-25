---
name: ianf-new-phpstan-rule
description: Create a new custom PHPStan rule as its own Composer package (ianflanagan1/phpstan-<name>), test-first, and optionally publish it to GitHub and Packagist. Use when the user wants a PHPStan rule that enforces a convention, especially one to reuse across projects.
argument-hint: <what the rule should report>
disable-model-invocation: true
allowed-tools: Bash(command -v github packagist), Bash(github publish:*), Bash(packagist publish:*)
---

# New PHPStan rule

Build one PHPStan rule as its own package in `~/projects/phpstan-rules/<name>/`, from the template next to this file. The scripts in `scripts/` do the mechanical steps; you do the parts that need judgement.

## 1. Settle the name and description

- **Name:** kebab-case, naming what the rule reports or enforces, e.g. `inferable-var-tag-name`. It becomes the package `ianflanagan1/phpstan-<name>`, which is permanent once on Packagist. Unless the user gave one, propose one or two and wait for their choice.
- **Description:** one sentence, starting "A PHPStan rule that reports …".

## 2. Find out what PHPStan actually does

Before encoding an assumption about PHPStan's behaviour in the rule, probe it: write a scratch file, analyse it at level 9 with `PHPStan\dumpType()`, and read the result. For example, check that the fix the rule will ask for really works in every place the rule reports. Note which cases the probes settled; they become fixtures.

## 3. Scaffold

```sh
<directory containing this file>/scripts/scaffold.sh <name> "<description>"
```

It creates the package (with its own git repo), installs dev dependencies with Docker, and prints the class, namespace and files still to write. It stops if the directory exists or the name is taken on Packagist.

## 4. Tests first

Write `tests/<Pascal>RuleTest.php`, extending `PHPStan\Testing\RuleTestCase`:

- One test method per behaviour, named for it: `test_a_var_tag_naming_the_assigned_variable_is_reported`.
- One fixture file per test in `tests/data/`, with namespace `<rule namespace>\Tests\data\<FixtureName>`. Fixtures are classmap-autoloaded, which PHPStan needs to analyse traits.
- Cover what must be reported **and** what must not: near-misses, other syntax for the same thing, closures, traits.
- `$this->analyse([file], [[message, line, tip?], ...])`. Build the rule in `getRule()`; get services like `FileTypeMapper` from `self::getContainer()->getByType(...)`.

Run `scripts/check.sh <dir>` and see the tests fail before writing the rule.

## 5. The rule

Write `src/<Pascal>Rule.php` as `final readonly class <Pascal>Rule implements Rule` with `@implements Rule<NodeType>`. `rules.neon` already registers it. Give every error an `->identifier('<category>.<name>')` and, where it helps, a `->tip(...)`. Its docblock says what it reports and what it deliberately leaves alone.

## 6. Check

1. Fill the README's `__WHAT_IT_REPORTS__` (with a short reported/preferred example) and `__IDENTIFIER__`.
2. Run `scripts/check.sh <dir>`. It fails on unfilled placeholders, an invalid `composer.json`, failing tests, PHPStan errors or Pint issues. Fix and repeat until it prints `check: all passed`.
3. Mutation check: break the rule's main condition, confirm tests fail, restore it, run `check.sh` again.

## 7. Commit and tag

In the package directory: `git add -A`, commit as `Add <Pascal>Rule` with a short body saying what it reports, and tag `v0.1.0`.

## 8. Publish

Only if the user asked to publish. Otherwise stop here and offer it.

First check both commands are on the PATH with `command -v github packagist`. If either is missing, stop and point the user to the setup in [repo-tools' README](https://github.com/ianflanagan1/repo-tools#setup); don't look for them elsewhere.

```sh
github publish <dir> phpstan-<name>
packagist publish <dir>
```

Each step is skipped when already done, so after a failure fix the cause and run the command again. If a command reports missing credentials, point the user to the same README; never try to log in or read tokens yourself.

## 9. Use it

If the user wanted the rule for a particular project, offer to require it there: `composer require --dev ianflanagan1/phpstan-<name> phpstan/extension-installer` (allowing `phpstan/extension-installer` under `config.allow-plugins`), then run that project's PHPStan and report what the rule finds.

## Report

Name the package, list the behaviours tested, give the GitHub and Packagist URLs if published, and say what's left for the user to do.
