<!-- The template slug "umami-railtools" is a placeholder until the template is published on Railway. Update the URL once the real slug is known. -->
[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/umami-railtools?referralCode=dPr4mc)

# Umami on Railway

[Umami](https://umami.is/) is an open-source, privacy-focused web analytics tool and an alternative to Google Analytics. It does not use cookies, keeps all data in your own database and gives you a simple dashboard for page views, visitors, referrers, events and more.

This repo wraps the official Umami image (`ghcr.io/umami-software/umami:3.5.0`, PostgreSQL build) for Railway.

## How it runs on Railway

- Two services: **Umami** (built from this repo's `Dockerfile`) and **Postgres** (Railway's database). Umami connects to Postgres over the private network through `DATABASE_URL`.
- On every start, Umami checks the database and runs any pending migrations automatically, then starts the web server. No manual setup of the database is needed.
- Umami listens on `PORT` (bound to `0.0.0.0`). The template sets `PORT=3000` and the public domain targets port 3000.
- Healthcheck: `GET /api/heartbeat` returns `{"ok":true}` (set in `railway.toml`).
- All data lives in Postgres. The Umami service itself is stateless and needs no volume.
- The server binds to IPv4 only (`0.0.0.0`, forced by the image's start script). That is fine for the public domain. If another service must reach Umami over Railway's private network, use the public domain or make sure the environment supports IPv4 private networking.

## Variables

| Variable | Value in the template | Purpose |
| --- | --- | --- |
| `DATABASE_URL` | `${{Postgres.DATABASE_URL}}` | Connection string for the Postgres service (private network) |
| `APP_SECRET` | `${{secret(64)}}` | Signs login tokens and hashes visitor data. Required. Do not change it after launch or everyone is logged out and visitor hashes change. |
| `PORT` | `3000` | Port Umami listens on, and the target port of the public domain |
| `TWO_FACTOR_ENCRYPTION_KEY` | `${{secret(64, "abcdef0123456789")}}` | Optional. 64 hex characters. Enables two-factor authentication. |

Other optional variables you can add (see the [Umami docs](https://umami.is/docs/environment-variables)):

- `TRACKER_SCRIPT_NAME`: rename the tracker script (for example `stats.js`) so ad blockers are less likely to block it.
- `DISABLE_TELEMETRY=1`: turn off Umami's anonymous telemetry.
- `REDIS_URL`: use Redis for login sessions and caching on busy instances.

## First login

1. Open the public domain of the Umami service.
2. Log in with the default account: username **`admin`**, password **`umami`**.
3. **Change the password immediately.** Everyone who finds your Umami URL can try the default login. Umami 3.5 asks you to change the seeded password before you can continue.

## Adding the tracking script

1. In Umami, go to **Settings > Websites > Add website** and enter the name and domain of your site.
2. Open the website's **Edit > Tracking code** and copy the snippet. It looks like this:

   ```html
   <script defer src="https://<your-umami-domain>/script.js" data-website-id="<website-id>"></script>
   ```

3. Paste it in the `<head>` of every page of your site. Visits appear in the dashboard within seconds.

## Run locally

`compose.yaml` runs Umami (built from the `Dockerfile`) and Postgres 18. It listens on `PORT`, which defaults to 8080 so the non-default port path is exercised like on Railway.

```sh
docker compose up -d --build
# open http://localhost:8080 and log in with admin / umami

curl http://localhost:8080/api/heartbeat   # {"ok":true}

docker compose down        # stop, keep data
docker compose down -v     # stop and delete the database volume
```

## Upgrading

Change the tag in the `Dockerfile` to a newer release from the [Umami releases](https://github.com/umami-software/umami/releases) (the image tag is the version without the `v`, for example `3.5.0`). Migrations run automatically on the next deploy. Read the release notes first and back up the database before major upgrades.
