# Custom Password Pusher image with branding modifications
# Based on the official pwpush image
FROM docker.io/pglombardo/pwpush:2.6.1

# Metadata
LABEL maintainer="Povilas <povilas@kulboka.com>"
LABEL description="Customized Password Pusher for DevOps final project"
LABEL version="1.0.0"

# Copy custom branding assets (logo, favicon, etc.)
# These override the default pwpush branding
# hadolint ignore=DL3059
COPY branding/logo.pn[g] /opt/PasswordPusher/app/assets/images/logo.png
COPY branding/favicon.ic[o] /opt/PasswordPusher/public/favicon.ico

# Copy custom configuration overrides
COPY config/custom_theme.cs[s] /opt/PasswordPusher/app/assets/stylesheets/custom_theme.css

# The base image already sets the entrypoint and CMD
# Environment variables are injected via docker-compose .env file

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:5100/ || exit 1
