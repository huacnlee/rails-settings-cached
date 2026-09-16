# Test/development image for rails-settings-cached.
#
#   docker compose build
#   docker compose run --rm test
#
# See DEVELOPMENT for more examples.
ARG RUBY_VERSION=3.4
FROM ruby:${RUBY_VERSION}-slim

RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends \
    build-essential git libyaml-dev libsqlite3-dev pkg-config \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ARG BUNDLE_GEMFILE=Gemfile
ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_GEMFILE=/app/${BUNDLE_GEMFILE}

# Install gems first, so the layer is cached across source code changes.
COPY Gemfile Gemfile.lock rails-settings-cached.gemspec ./
COPY gemfiles/ gemfiles/
COPY lib/rails-settings/version.rb lib/rails-settings/version.rb
RUN bundle install --jobs 4

COPY . .

ENTRYPOINT ["bin/docker-entrypoint"]
CMD ["bundle", "exec", "rails", "test"]
