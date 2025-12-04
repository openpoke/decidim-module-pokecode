# Decidim::Pokecode

[![[CI] Lint](https://github.com/openpoke/decidim-module-pokecode/actions/workflows/lint.yml/badge.svg)](https://github.com/openpoke/decidim-module-pokecode/actions/workflows/lint.yml)
[![[CI] Test](https://github.com/openpoke/decidim-module-pokecode/actions/workflows/test.yml/badge.svg)](https://github.com/openpoke/decidim-module-pokecode/actions/workflows/test.yml)
[![Maintainability](https://qlty.sh/gh/openpoke/projects/decidim-module-pokecode/maintainability.svg)](https://qlty.sh/gh/openpoke/projects/decidim-module-pokecode)
[![codecov](https://codecov.io/gh/openpoke/decidim-module-pokecode/graph/badge.svg?token=2pG5xs2PE7)](https://codecov.io/gh/openpoke/decidim-module-pokecode)

A Decidim module that adds Pokecode functionality to your Decidim application.

> This module is not meant to be used outside Pokecode Decidim instance.

## Usage

This plugin relies on the command `decidim:upgrade` to make sure common files are installed in the Decidim application. It is possible to customize which features are activated through ENV vars:

| ENV Variable | Description | Default |
|---|---|---|
| `DISABLE_HEALTH_CHECK` | Disables the gem `health_check` and the endpoint `/health_check` | `false` |
| `DISABLE_SEMANTIC_LOGGER` | Disables the gem `rails_semantic_logger` and the configuration for production logging that this gem provides. Note that this feature will override the existing `config/puma.rb` file after a `decidim:upgrade` command. | `false` |

## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-pokecode", github: "openpoke/decidim-module-pokecode"
```

And then execute:

```bash
bundle install
bin/rails decidim:upgrade
```

Depending on your Decidim version, choose the corresponding Awesome version to ensure compatibility:

| Pokecde version | Compatible Decidim versions |
|---|---|
| 0.1.x | 0.30.x |

## Contributing

Contributions are welcome if, for some reason you find this module is interesting to you.

We expect the contributions to follow the [Decidim's contribution guide](https://github.com/decidim/decidim/blob/develop/CONTRIBUTING.adoc).

## Security

Security is very important to us. If you have any issue regarding security, please disclose the information responsibly by sending an email to __ivan [at] pokecode [dot] net__ and not by creating a GitHub issue.

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.
