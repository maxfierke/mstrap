FROM alpine:3.14.0

RUN \
  apk add --update --no-cache --force-overwrite \
    # Crystal dependencies
    build-base git gc-dev libevent-dev pcre-dev zlib-dev \
    libxml2-dev yaml-dev openssl-dev gmp-dev zlib-dev \
    # Crystal
    crystal shards \
    # mstrap depedencies (used by Crystal stdlib)
    readline-dev \
    readline-static \
    ncurses-dev \
    ncurses-static \
    openssl-libs-static \
    zlib-static

CMD [ "/bin/sh" ]
