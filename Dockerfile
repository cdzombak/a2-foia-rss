ARG BIN_VERSION=<unknown>

FROM ruby:3.2.2-alpine
ARG BIN_VERSION
ENV BUNDLER_VERSION=2.4.10

RUN apk add --update --no-cache build-base gcompat
RUN gem install bundler -v ${BUNDLER_VERSION}
WORKDIR /app
COPY *.rb Gemfile Gemfile.lock ./
RUN bundle install
RUN mkdir -p /app/public && chmod 0755 /app/public
ENTRYPOINT ["bundle", "exec", "ruby", "/app/build_rss.rb"]

LABEL license="MIT"
LABEL maintainer="Chris Dzombak <https://www.dzombak.com>"
LABEL org.opencontainers.image.authors="Chris Dzombak <https://www.dzombak.com>"
LABEL org.opencontainers.image.url="https://github.com/cdzombak/a2-foia-rss"
LABEL org.opencontainers.image.documentation="https://github.com/cdzombak/a2-foia-rss/blob/main/README.md"
LABEL org.opencontainers.image.source="https://github.com/cdzombak/a2-foia-rss.git"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.title="a2-foia-rss"
LABEL org.opencontainers.image.version="${BIN_VERSION}"
