# Pinned to the official Umami v3.5.0 image (PostgreSQL build) for reproducible
# deploys. Since v3 the tags are plain versions; to upgrade, pick a newer
# release from https://github.com/umami-software/umami/releases and use the
# matching ghcr.io/umami-software/umami:X.Y.Z tag.
FROM ghcr.io/umami-software/umami:3.5.0

# The image's start script runs the database migrations, updates the tracker
# script name, then starts the Next.js server on $PORT bound to 0.0.0.0.
# Railway injects PORT at runtime and it overrides the image default (3000).
EXPOSE 3000
