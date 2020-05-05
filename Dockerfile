FROM crystallang/crystal:0.34.0-alpine

RUN apk add --update-cache \
    readline-dev \
    readline-static \
    ncurses-dev \
    ncurses-static \
  && rm -rf /var/cache/apk/*
