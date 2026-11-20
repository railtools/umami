# Railway template setup

How to configure the Umami template in the Railway dashboard (Workspace > Templates > New Template).

## Template details

- **Name:** Umami
- **Suggested slug:** `umami-railtools` (the README button uses this; update it if the published slug differs)
- **Category:** Analytics
- **Short description:** Privacy-focused, cookie-free web analytics with Postgres. A self-hosted Google Analytics alternative.

## Services

### 1. Postgres

- Add a **Database > PostgreSQL** service (Railway's own Postgres template, with its volume).
- Keep the service name **`Postgres`**, because the Umami variables reference it by name.
- No changes to its variables.

### 2. Umami

- Add a **GitHub Repo** service: `railtools/umami`, branch `main`. No root directory.
- Service name: **`Umami`**.
- Build and deploy settings come from `railway.toml` (Dockerfile builder, healthcheck `/api/heartbeat`, timeout 300 s, restart on failure, max 10 retries). Nothing to set in the dashboard.
- **Variables:**

  | Name | Value | Notes |
  | --- | --- | --- |
  | `DATABASE_URL` | `${{Postgres.DATABASE_URL}}` | Private-network connection string |
  | `APP_SECRET` | `${{secret(64)}}` | Required; the server refuses logins without it. Replaces the old `HASH_SALT`, which current Umami no longer reads. Generated once per deploy. |
  | `PORT` | `3000` | Umami listens on this port; matches the domain target port |
  | `TWO_FACTOR_ENCRYPTION_KEY` | `${{secret(64, "abcdef0123456789")}}` | Optional. Must be exactly 64 hex characters, so restrict the alphabet to hex. |

  Variable descriptions to enter in the template editor:
  - `DATABASE_URL`: Postgres connection string for Umami.
  - `APP_SECRET`: Random secret used to sign logins and hash visitor data. Do not change it after launch.
  - `PORT`: Port Umami listens on.
  - `TWO_FACTOR_ENCRYPTION_KEY`: 64-character hex key that enables two-factor authentication.

- **Networking:** enable a public domain (**Generate Domain**) with **target port `3000`**.
- **Volume:** none. All data lives in Postgres.

## Overview text

Paste this into the template's overview field:

```markdown
# Deploy and Host Umami on Railway

Umami is an open-source, privacy-focused web analytics tool. It tracks page views, visitors, referrers, devices, countries and custom events without cookies, and keeps all data in your own Postgres database. A simple, fast alternative to Google Analytics that is GDPR friendly out of the box.

## About Hosting Umami

This template runs the official Umami image (pinned to a stable release) next to a Railway Postgres database. Umami connects over the private network, runs its database migrations automatically on every start and exposes its dashboard and tracker script on a public domain. A random `APP_SECRET` is generated for you. The Umami service is stateless, so redeploys and upgrades only touch the database through Umami's own migrations.

## Common Use Cases

- Privacy-friendly analytics for websites, blogs and documentation sites
- Replacing Google Analytics without a cookie banner
- Tracking custom events, UTM campaigns and goals across several sites from one dashboard

## Dependencies for Umami Hosting

- PostgreSQL (included in this template)

### Deployment Dependencies

- Umami: https://github.com/umami-software/umami
- Documentation: https://umami.is/docs
- Template source: https://github.com/railtools/umami

### Implementation Details

After deploying, open the public domain and log in with username `admin` and password `umami`. Change the password right away. Then add a website under Settings > Websites and paste the tracking snippet into the `<head>` of your site:

    <script defer src="https://<your-umami-domain>/script.js" data-website-id="<website-id>"></script>

## Why Deploy Umami on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Umami on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
```

## Check after publishing

1. Deploy the template into a fresh project.
2. The Umami deploy log shows the migrations being applied, then the healthcheck on `/api/heartbeat` passes.
3. The public domain shows the login page; `admin` / `umami` works and asks for a new password.
4. Replace the placeholder slug in the README deploy button with the published one.
