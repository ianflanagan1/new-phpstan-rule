# phpstan-__NAME__

__DESCRIPTION__

## Installation

```sh
composer require --dev __PACKAGE__
```

With [phpstan/extension-installer](https://github.com/phpstan/extension-installer) the rule is enabled automatically. Otherwise, include it in your `phpstan.neon`:

```neon
includes:
    - vendor/__PACKAGE__/rules.neon
```

Requires PHP 8.3+ and PHPStan 2.1+.

## What it reports

__WHAT_IT_REPORTS__

Identifier: `__IDENTIFIER__`. To ignore one occurrence, add `// @phpstan-ignore __IDENTIFIER__` to the line.

## Development

```sh
composer install
vendor/bin/phpunit
vendor/bin/phpstan analyse
vendor/bin/pint --test
```

The test in `tests/` is built on PHPStan's `RuleTestCase`, with fixture files in `tests/data/`. The fixtures break the rule on purpose, so PHPStan and Pint skip them.

## License

MIT
