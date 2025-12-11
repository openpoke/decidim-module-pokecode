# Decidim::Pokecode

[![[CI] Lint](https://github.com/openpoke/decidim-module-pokecode/actions/workflows/lint.yml/badge.svg)](https://github.com/openpoke/decidim-module-pokecode/actions/workflows/lint.yml)
[![[CI] Test](https://github.com/openpoke/decidim-module-pokecode/actions/workflows/test.yml/badge.svg)](https://github.com/openpoke/decidim-module-pokecode/actions/workflows/test.yml)
[![Maintainability](https://qlty.sh/gh/openpoke/projects/decidim-module-pokecode/maintainability.svg)](https://qlty.sh/gh/openpoke/projects/decidim-module-pokecode)
[![codecov](https://codecov.io/gh/openpoke/decidim-module-pokecode/graph/badge.svg?token=2pG5xs2PE7)](https://codecov.io/gh/openpoke/decidim-module-pokecode)

A Decidim module that adds Pokecode functionality to your Decidim application.

> This module is not meant to be used outside Pokecode Decidim instance.

## Usage

This plugin relies on the command `decidim:upgrade` to make sure common files are installed in the Decidim application. It is possible to customize which features are activated through ENV vars:

| ENV Variable | Description | Default | PR |
|---|---|---|---|
| `DISABLE_HEALTH_CHECK` | Disables the gem `health_check` and the endpoint `/health_check` | `false` | |
| `DISABLE_SEMANTIC_LOGGER` | Disables the gem `rails_semantic_logger` and the configuration for production logging that this gem provides.<br>Note that this feature will override the existing `config/puma.rb` file after a `decidim:upgrade` command. | `false` | |
| `DISABLE_POKECODE_FOOTER` | Disables the Pokecode footer deface override so the footer stays unchanged. | `false` | |
| `DISABLE_LANGUAGE_MENU` | Disables the language switcher deface override in the header. | `false` | |
| `DISABLE_ASSEMBLY_MEMBERS_VISIBLE` | Disables the assembly members visibility feature (public assemblies won't have members page). | `false` | [#9](https://github.com/openpoke/decidim-module-pokecode/pull/9) |
| `DISABLE_SIDEKIQ` | Disables Sidekiq integration and the `/sidekiq` Web UI endpoint. | `false` | [#11](https://github.com/openpoke/decidim-module-pokecode/pull/11) |
| `SENTRY_DSN` | Enables Sentry error tracking integration. Provide the DSN URL from your Sentry project. | `""` (disabled) | [#10](https://github.com/openpoke/decidim-module-pokecode/pull/10) |
| `UMAMI_ANALYTICS_ID` | Enable Umami analytics by setting the website ID provided by your Umami instance. When set together with `UMAMI_ANALYTICS_URL` the analytics script is injected in the page head. | `""` (disabled) | |
| `UMAMI_ANALYTICS_URL` | URL to the Umami `script.js` file. Defaults to the hosted Pokecode analytics script. | `"https://analytics.pokecode.net/script.js"` | |
| `ADMIN_IFRAME_URL` | Enables the admin iframe feature and embeds the specified URL in the admin dashboard. When set, a new iframe page becomes available at `/admin/iframe`. | `""` (disabled) | [#12](https://github.com/openpoke/decidim-module-pokecode/pull/12) |
| `ADMIN_IFRAME_TITLE` | Customizes the label of the admin iframe menu item in the admin sidebar. | `"Web Stats"` | [#12](https://github.com/openpoke/decidim-module-pokecode/pull/12) |
| `RACK_ATTACK_SKIP_PARAM` | Secret value compared against the `skip_rack_attack` request parameter to bypass Rack::Attack rate limiting (useful for performance testing). If unset, defaults to the first 6 characters of `Rails.application.secrets.secret_key_base`. If empty, it will be disabled. | first 6 chars of Rails secret | |
| `RACK_ATTACK_ALLOWED_IPS` | Comma or space-separated list of IP addresses to safelist from Rack::Attack rate limiting. If not set, no IPs are safelisted by default. | none (empty) | |
| `HEALTHCHECK_ADDITIONAL_CHECKS` | Additional healthcheck checks to run (space-separated list). Appends to the standard health checks when `health_check` gem is enabled. | `""` (none) | |
| `HEALTHCHECK_EXCLUDE_CHECKS` | Health check names to exclude from the standard checks (space-separated, default excludes `emailconf`). | `"emailconf"` | |
| `AWS_CDN_HOST` | Optional CDN host (https://...) used to serve uploaded assets; when set, it's added to ActiveStorage S3 URLs and whitelisted in CSP. This is required for alternative S3 providers that do not use the name of the bucket as the fully qualified CDN name (ie: Cloudflare). | `""` (disabled) | |
| `AWS_PUBLIC` | Usually, to be used in combination with the previous option. This generates assets without signatures, which basically means they don't expire. | `true` | |
| `AWS_FORCE_PATH_STYLE` | Certain providers do not support the bucket name as the subdomain of the AWS endpoint (ie: Contabo). Set to `true` if that's the case. | `false` | |

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
