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
| `DISABLE_SEMANTIC_LOGGER` | Disables the gem `rails_semantic_logger` and the configuration for production logging that this gem provides. | `false` | |
| `DISABLE_POKECODE_FOOTER` | Disables the Pokecode footer deface override so the footer stays unchanged. | `false` | |
| `QUEUE_ADAPTER` | Active Job backend. `solid_queue` stores the jobs in the application database (see [Background jobs](#background-jobs)). Any other Active Job adapter name (e.g. `async`) is set as is; an empty value keeps the Rails default and loads no queue backend. | `solid_queue` | |
| `SOLID_QUEUE_IN_PUMA` | Runs the Solid Queue supervisor (worker, dispatcher and scheduler) under Puma's management, so jobs run in the web container without a separate jobs container. Set it to `false` when jobs run in a dedicated container with `bin/jobs`. | `true` | |
| `JOB_CONCURRENCY` | Number of Solid Queue worker processes per supervisor. Each worker process is configured with 3 threads. | `1` | |
| `SENTRY_DSN` | Enables Sentry error tracking integration. Provide the DSN URL from your Sentry project. | `""` (disabled) | [#10](https://github.com/openpoke/decidim-module-pokecode/pull/10) |
| `UMAMI_ANALYTICS_ID` | Enable Umami analytics by setting the website ID provided by your Umami instance. When set together with `UMAMI_ANALYTICS_URL` the analytics script is injected in the page head. | `""` (disabled) | |
| `UMAMI_ANALYTICS_URL` | URL to the Umami `script.js` file. Defaults to the hosted Pokecode analytics script. | `"https://analytics.pokecode.net/script.js"`. The host is automatically added to the CSP directives. | |
| `ADMIN_IFRAME_URL` | Enables the admin iframe feature and embeds the specified URL in the admin dashboard. When set, a new iframe page becomes available at `/admin/iframe`. The host of the iframe is automatically added to the CSP directives. | `""` (disabled) | [#12](https://github.com/openpoke/decidim-module-pokecode/pull/12) |
| `ADMIN_IFRAME_TITLE` | Customizes the label of the admin iframe menu item in the admin sidebar. | `"Web Stats"` | [#12](https://github.com/openpoke/decidim-module-pokecode/pull/12) |
| `UNSAFE_HTML_BLOCKS` | Disables HTML sanitization in the HTML content block, allowing raw HTML (including iframes, scripts, etc.) to be rendered as-is. Useful when admin users are fully trusted. | `false` | |
| `RACK_ATTACK_SKIP_PARAM` | Optional secret value compared against the `skip_rack_attack` request parameter to bypass Rack::Attack rate limiting (useful for performance testing). Use a long, randomly generated value. When unset or empty, the bypass is disabled. | `""` (disabled) | |
| `RACK_ATTACK_ALLOWED_IPS` | Comma or space-separated list of IP addresses to safelist from Rack::Attack rate limiting. If not set, no IPs are safelisted by default. | none (empty) | |
| `HEALTHCHECK_ADDITIONAL_CHECKS` | Additional healthcheck checks to run (space-separated list). Appends to the standard health checks when `health_check` gem is enabled. | `""` (none) | |
| `HEALTHCHECK_EXCLUDE_CHECKS` | Health check names to exclude from the standard checks (space-separated, default excludes `emailconf`). | `"emailconf"` | |
| `AWS_CDN_HOST` | Optional CDN host (https://...) used to serve uploaded assets; when set, it's added to ActiveStorage S3 URLs and safelisted in CSP. This is required for alternative S3 providers that do not use the name of the bucket as the fully qualified CDN name (ie: Cloudflare). | `""` (disabled) | |
| `AWS_PUBLIC` | Usually, to be used in combination with the previous option. This generates assets without signatures, which basically means they don't expire. | `true` | |
| `AWS_FORCE_PATH_STYLE` | Certain providers do not support the bucket name as the subdomain of the AWS endpoint (ie: Contabo). Set to `true` if that's the case. | `false` | |
| `CONTENT_SECURITY_POLICY` | Sets custom Content Security Policy headers for enhanced security. When set, it is added to the default CSP configuration. | `""` (disabled) | |
| `ALLOWED_RECIPIENTS` | A list of emails or domains that must match in order to send an email, separated by spaces. For instance `@pokecode.net johnsmith@gmail.com`. Exact email addresses (without a leading `@`) must match the full recipient email, while domain patterns starting with `@` are matched as suffixes of the recipient email. Leave empty to disable any interception. | `""` |
| `DISABLE_INVITATIONS` | Prevents all invitation emails from being sent by intercepting emails with the `invitation-instructions` header. This is useful for development or testing environments. | `false` | |
| `DISABLE_EMAIL_WHITE_HEADER` | Disables the white header deface override injected into email and newsletter layouts (`layouts/decidim/mailer` and `layouts/decidim/newsletter_base`). | `false` | |
| `DISABLE_LOCALE_GET_PATH` | Disables the locale-switching via GET request (`GET /locale`). When enabled, the route is registered as `set_locale` so the locale can be changed with a plain link instead of a form POST. | `false` | |

## Background jobs

Background jobs run on [Solid Queue](https://github.com/rails/solid_queue) and are stored in the application database, so no Redis is needed. By default, the Solid Queue supervisor runs in a separate process managed by the Puma plugin, in the same web container.

The command `decidim:upgrade` installs everything that is required: the migrations with the Solid Queue tables (new ones come through `solid_queue:update`), `config/queue.yml`, `config/recurring.yml` (the scheduled tasks), `bin/jobs` and the `plugin :solid_queue` line in `config/puma.rb`. To install only the migrations:

```bash
bin/rails decidim_pokecode:install:migrations
bin/rails solid_queue:update
bin/rails db:migrate
```

| Deployment | ENV vars |
|---|---|
| Web and jobs in the same container (default) | none |
| Dedicated jobs container | `SOLID_QUEUE_IN_PUMA=false` in the web container, `bin/jobs` as the command of the jobs container |

Notes:

- `WEB_CONCURRENCY` controls Puma web workers; it does not change Solid Queue concurrency. `JOB_CONCURRENCY` controls the number of Solid Queue worker processes, each with 3 threads. The default is one worker process, so it can run up to 3 jobs concurrently.
- When `SOLID_QUEUE_IN_PUMA` is enabled, each Puma instance starts its own Solid Queue supervisor. Scaling the web deployment to multiple instances therefore scales job processing too. Set `SOLID_QUEUE_IN_PUMA=false` on web instances when running a separate jobs container.
- Jobs, queues, workers and failed jobs are listed at `/solid_queue` (admin users only). Failed jobs can be retried or discarded there.
- Decidim jobs and mail deliveries are retried up to 10 attempts with a growing delay (about 4 hours in total), then they are listed as failed in `/solid_queue`. The scheduled tasks of `config/recurring.yml` are not retried, they run again at their next scheduled time. They can be disabled with ENV vars (e.g. `EXPORT_OPEN_DATA=disabled`, see the file).
- Keep `RAILS_MAX_THREADS` at 5 or more (the Rails default): each Solid Queue worker needs 5 database connections (3 threads, polling and heartbeat).
- When switching from another backend, let it process its pending jobs first: they are not moved to the database.

### Docker deployments

Use the same application Dockerfile and image in both deployment layouts; no separate jobs image is required.

**Single container (default):** the image's default command starts Puma. With `SOLID_QUEUE_IN_PUMA=true` (the default), Puma also manages the Solid Queue supervisor in the same container. Publish port `3000` and configure `JOB_CONCURRENCY` as needed.

**Separate web and jobs containers:** build the image once, run it for the web service with `SOLID_QUEUE_IN_PUMA=false`, and run the same image for jobs with `bin/jobs`. For example:

```yaml
services:
  web:
    build: .
    image: decidim-app:latest
    env_file: .env
    environment:
      SOLID_QUEUE_IN_PUMA: "false"
    ports:
      - "3000:3000"

  jobs:
    image: decidim-app:latest
    env_file: .env
    environment:
      SOLID_QUEUE_IN_PUMA: "false"
      SKIP_MIGRATIONS: "true"
    command: ["bin/jobs"]
    healthcheck:
      disable: true
```

The jobs container uses the same database and other application settings as the web container. `SKIP_MIGRATIONS=true` avoids running the image entrypoint's migration step a second time; run migrations once as part of deployment. The Dockerfile health check targets the web endpoint, so it is disabled for the jobs service. Scale the web service to adjust web capacity with `WEB_CONCURRENCY`; scale the jobs service or set `JOB_CONCURRENCY` to adjust job capacity.

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

| Pokecode version | Compatible Decidim versions |
|---|---|
| 0.3.x | 0.32.x |
| 0.2.x | 0.31.x |
| 0.1.x | 0.30.x |

## Contributing

Contributions are welcome if, for some reason you find this module is interesting to you.

We expect the contributions to follow the [Decidim's contribution guide](https://github.com/decidim/decidim/blob/develop/CONTRIBUTING.adoc).

### Testing

```bash
bundle exec rake test_app
bundle exec rspec spec
```

## Security

Security is very important to us. If you have any issue regarding security, please disclose the information responsibly by sending an email to __ivan [at] pokecode [dot] net__ and not by creating a GitHub issue.

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.
