FROM alpine:3.12.0

RUN \
  apk add --update --no-cache --force-overwrite \
    # Crystal dependencies
    build-base git gc-dev llvm-dev libevent-dev pcre-dev zlib-dev \
    libxml2-dev yaml-dev openssl-dev gmp-dev zlib-dev \
    # mstrap depedencies (used by Crystal stdlib)
    readline-dev \
    readline-static \
    ncurses-dev \
    ncurses-static \
    openssl-libs-static \
    zlib-static

# Install latest crystal from edge
RUN apk add --update --no-cache \
  --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
  crystal

CMD [ "/bin/sh" ]
