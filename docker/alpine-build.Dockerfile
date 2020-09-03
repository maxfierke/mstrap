FROM crystallang/crystal:0.35.1-alpine

RUN apk add --update-cache \
    readline-dev \
    readline-static \
    ncurses-dev \
    ncurses-static \
  && rm -rf /var/cache/apk/*
