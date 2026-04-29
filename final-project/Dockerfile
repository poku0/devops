# =============================================================================
# Custom Password Pusher — built from forked source (poku0/PasswordPusher)
# Multi-stage build based on upstream containers/docker/Dockerfile
# =============================================================================

# ── Global build args ────────────────────────────────────────────────────────
ARG BUNDLE_WITHOUT=development:test
ARG BUNDLE_DEPLOYMENT=true
ARG FORK_REPO=https://github.com/poku0/PasswordPusher.git
ARG FORK_BRANCH=master

# =============================================================================
# Stage 1: Clone fork + install dependencies + compile assets
# =============================================================================
FROM ruby:4.0.3-alpine AS build-env

ARG BUNDLE_WITHOUT
ARG BUNDLE_DEPLOYMENT
ARG FORK_REPO
ARG FORK_BRANCH

LABEL org.opencontainers.image.authors="Povilas <povilas@kulboka.com>"
LABEL org.opencontainers.image.description="Customized Password Pusher — DevOps final project"
LABEL org.opencontainers.image.source="https://github.com/poku0/PasswordPusher"
LABEL org.opencontainers.image.version="1.0.0"

# Install build dependencies (single layer)
# hadolint ignore=DL3018
RUN apk update && apk add --no-cache \
    git \
    build-base \
    musl-dev \
    libc6-compat \
    libpq-dev \
    mariadb-dev \
    nodejs \
    sqlite-dev \
    tzdata \
    yaml-dev \
    yarn \
    pkgconf \
    openssl-dev \
    libffi-dev

ENV APP_ROOT=/opt/PasswordPusher
ENV RACK_ENV=production RAILS_ENV=production

WORKDIR ${APP_ROOT}

# Clone the forked repository
RUN git clone --depth 1 --branch ${FORK_BRANCH} ${FORK_REPO} ${APP_ROOT}

# ── Apply custom branding ───────────────────────────────────────────────────
# Copy branding assets over the cloned source (logo, favicon)
COPY branding/logo.png ${APP_ROOT}/app/assets/images/logo.png
COPY branding/favicon.ico ${APP_ROOT}/public/favicon.ico

# Copy custom CSS theme
COPY config/custom_theme.css ${APP_ROOT}/app/assets/stylesheets/custom_theme.css

# ── Install Ruby dependencies ───────────────────────────────────────────────
RUN bundle config set without "${BUNDLE_WITHOUT}" \
    && bundle config set deployment "${BUNDLE_DEPLOYMENT}" \
    && bundle install \
    && rm -rf vendor/bundle/ruby/*/cache \
    && rm -rf vendor/bundle/ruby/*/bundler/gems/*/.git \
    && find vendor/bundle/ruby/*/gems/ -name "*.c" -delete \
    && find vendor/bundle/ruby/*/gems/ -name "*.o" -delete

# ── Install Node.js dependencies ────────────────────────────────────────────
RUN yarn install --frozen-lockfile

# ── Precompile bootsnap (amd64 only) ────────────────────────────────────────
RUN if [ "$(uname -m)" = "x86_64" ]; then \
      SECRET_KEY_BASE_DUMMY=1 bundle exec bootsnap precompile --gemfile && \
      SECRET_KEY_BASE_DUMMY=1 bundle exec bootsnap precompile app/ lib/ ; \
    else \
      echo "Skipping bootsnap precompilation for $(uname -m)" ; \
    fi

# ── Precompile Rails assets + clean up ───────────────────────────────────────
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile \
    && rm -rf tmp/cache tmp/pids tmp/sockets app/assets/images/features .git

# =============================================================================
# Stage 2: Production runtime image
# =============================================================================
FROM ruby:4.0.2-alpine

ARG BUNDLE_WITHOUT
ARG BUNDLE_DEPLOYMENT

LABEL maintainer="Povilas <povilas@kulboka.com>"
LABEL description="Customized Password Pusher — DevOps final project"

# Install runtime packages (single layer)
# hadolint ignore=DL3018
RUN apk update && apk add --no-cache \
    bash \
    curl \
    libc6-compat \
    libpq \
    mariadb-connector-c \
    nodejs \
    tzdata \
    yarn \
    jemalloc

ARG UID=1000
ARG GID=1000

ENV LC_CTYPE=UTF-8 LC_ALL=en_US.UTF-8
ENV APP_ROOT=/opt/PasswordPusher
ENV RACK_ENV=production RAILS_ENV=production
ENV LD_PRELOAD=/usr/lib/libjemalloc.so.2

WORKDIR ${APP_ROOT}

# Create non-root user
RUN addgroup -g "${GID}" pwpusher \
  && adduser -D -u "${UID}" -G pwpusher pwpusher

# Copy application from build stage
COPY --from=build-env --chown=pwpusher:pwpusher ${APP_ROOT} ${APP_ROOT}

# Configure bundle, create dirs, set up entrypoints, clean up (single layer)
RUN bundle config set without "${BUNDLE_WITHOUT}" \
    && bundle config set deployment "${BUNDLE_DEPLOYMENT}" \
    && mkdir -p ${APP_ROOT}/storage/db \
    && chown -R pwpusher:pwpusher ${APP_ROOT}/storage \
    && chmod +x ${APP_ROOT}/containers/docker/entrypoint.sh \
                ${APP_ROOT}/containers/docker/worker-entrypoint.sh \
    && cp ${APP_ROOT}/containers/docker/entrypoint.sh /usr/local/bin/docker-entrypoint \
    && cp ${APP_ROOT}/containers/docker/worker-entrypoint.sh /usr/local/bin/docker-worker-entrypoint \
    && rm -rf ${APP_ROOT}/.do \
              ${APP_ROOT}/.github \
              ${APP_ROOT}/app.json \
              ${APP_ROOT}/bin/move_up_stable_tag.sh \
              ${APP_ROOT}/test \
              ${APP_ROOT}/ct.yaml \
    && touch /opt/PasswordPusher/.env.production \
    && chown pwpusher:pwpusher /opt/PasswordPusher/.env.production

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
  CMD curl -f http://localhost:5100/ || exit 1

USER pwpusher
EXPOSE 5100

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
