ARG RUBY_VERSION=3.4.3

FROM docker.io/library/node:20.19.0-bullseye-slim AS node
FROM ruby:${RUBY_VERSION}-slim-bullseye

ARG GIT_COMMIT

ENV APP_DIR=/app
ENV BUNDLE_PATH=/usr/local/bundle
ENV LANG=C.UTF-8

WORKDIR $APP_DIR

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      ca-certificates \
      curl \
      default-libmysqlclient-dev \
      ffmpeg \
      fonts-dejavu \
      git \
      imagemagick \
      libcurl4-openssl-dev \
      liblzma-dev \
      libssl-dev \
      libvips-dev \
      libxml2-dev \
      libyaml-dev \
      pkg-config \
      zlib1g-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/include/node /usr/local/include/node

RUN ln -sf ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -sf ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx && \
    ln -sf ../lib/node_modules/corepack/dist/corepack.js /usr/local/bin/corepack && \
    chmod +x /usr/local/lib/node_modules/npm/bin/npm-cli.js \
             /usr/local/lib/node_modules/npm/bin/npx-cli.js \
             /usr/local/lib/node_modules/corepack/dist/corepack.js

COPY Gemfile Gemfile.lock .ruby-version ./

RUN gem install bundler:$(awk '/BUNDLED WITH/{getline; print}' Gemfile.lock | tr -d " ") && \
    bundle config set without 'development test deployer' && \
    bundle install --jobs=3 --retry=3

COPY package.json package-lock.json .npmrc ./
RUN npm ci

COPY . ./

ENV RAILS_ENV=staging \
    RACK_ENV=staging \
    NODE_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    ASSET_HOST="" \
    SECRET_KEY_BASE=build-placeholder-secret-key-base \
    DEVISE_SECRET_KEY=build-placeholder-devise-secret-key \
    RENDERER_PASSWORD=build-placeholder-renderer-password \
    REACT_ON_RAILS_PRO_LICENSE="" \
    DATABASE_HOST=127.0.0.1 \
    DATABASE_PORT=3306 \
    DATABASE_NAME=gumroad_demo \
    DATABASE_USERNAME=gumroad \
    DATABASE_PASSWORD=gumroad \
    MONGO_DATABASE_URL=127.0.0.1:27017 \
    MONGO_DATABASE_NAME=gumroad_log_demo \
    MONGO_DATABASE_USERNAME=gumroad \
    MONGO_DATABASE_PASSWORD=gumroad \
    MONGO_AUTH_SOURCE=admin \
    REDIS_HOST=127.0.0.1:6379/0 \
    SIDEKIQ_REDIS_HOST=127.0.0.1:6379/1 \
    RPUSH_REDIS_HOST=127.0.0.1:6379/2 \
    RACK_ATTACK_REDIS_HOST=127.0.0.1:6379/3 \
    MEMCACHE_SERVERS=127.0.0.1:11211 \
    ELASTICSEARCH_HOST=http://127.0.0.1:9200 \
    AWS_ACCESS_KEY_ID=demo-access-key \
    AWS_SECRET_ACCESS_KEY=demo-secret-key \
    AWS_DEFAULT_REGION=us-east-1 \
    BRANCH_DEPLOYMENT=true \
    BRANCH=control-plane-build \
    REVISION=control-plane-build \
    GIT_COMMIT=${GIT_COMMIT}

RUN export STRONGBOX_GENERAL="$(ruby -ropenssl -e 'print OpenSSL::PKey::RSA.generate(2048).to_pem')" && \
    export STRONGBOX_GENERAL_PASSWORD="" && \
    export SKIP_BRANCH_APP_ES_INDEX_SETUP=true && \
    npm run setup && \
    bin/shakapacker && \
    npm run build:rsc-demo && \
    bundle exec rails assets:precompile

COPY .controlplane/entrypoint.sh ./
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
