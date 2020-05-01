MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

CRYSTAL_BIN       ?= $(shell which crystal)
SHARDS_BIN        ?= $(shell which shards)
MSTRAP_BIN        ?= $(shell which mstrap)
LIBEVENT_LIB_PATH ?= $(shell pkg-config --libs-only-L libevent | cut -c 3-)
LIBPCRE_LIB_PATH  ?= $(shell pkg-config --libs-only-L libpcre | cut -c 3-)

PREFIX            ?= /usr/local
RELEASE           ?=
STATIC            ?=
STATIC_LIBS_DIR   := $(CURDIR)/vendor
SOURCES           := src/*.cr src/**/*.cr
UNAME_S           := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
  export MACOSX_DEPLOYMENT_TARGET=10.12
  OPENSSL_LIB_PATH ?= $(shell brew --prefix openssl@1.1)/lib
  export PKG_CONFIG_PATH=$(OPENSSL_LIB_PATH)/pkgconfig

  .PHONY: libs
  libs: vendor/libcrypto.a vendor/libssl.a vendor/libevent.a vendor/libpcre.a
else
  .PHONY: libs
  libs:
endif

override LDFLAGS += -L$(STATIC_LIBS_DIR)
override CRFLAGS += $(if $(RELEASE),--release ,--debug --error-trace )$(if $(STATIC),--static )$(if $(LDFLAGS),--link-flags="$(LDFLAGS)" )

.PHONY: all
all: build

bin/mstrap: deps libs $(SOURCES)
	mkdir -p bin
	$(CRYSTAL_BIN) build -o bin/mstrap src/cli.cr $(CRFLAGS)

.PHONY: build
build: bin/mstrap

.PHONY: deps
deps: shard.yml shard.lock
	$(SHARDS_BIN) check || $(SHARDS_BIN) install

docs: $(SOURCES)
	$(CRYSTAL_BIN) docs

format:
	$(CRYSTAL_BIN) tool format

.PHONY: clean
clean:
	rm -f ./bin/mstrap*
	rm -rf ./dist
	rm -rf ./docs
	rm -rf ./vendor/*.a

.PHONY: spec
spec: libs deps $(SOURCES)
	$(CRYSTAL_BIN) tool format --check
	# crystal spec doesn't support link-flags: https://github.com/crystal-lang/crystal/issues/6231
	LIBRARY_PATH=$(STATIC_LIBS_DIR) $(CRYSTAL_BIN) spec -Dmt_no_expectations

.PHONY: check-libraries
check-libraries: bin/mstrap
	@if [ "$$(uname -s)" == "Darwin" ] && [ "$$(otool -LX bin/mstrap | awk '{print $$1}')" != "$$(cat expected.libs.darwin)" ]; then \
		echo "FAIL: bin/mstrap has non-allowed dynamic libraries"; \
		exit 1; \
	else \
		echo "OK: bin/mstrap has only allowed dynamic libraries"; \
		exit 0; \
	fi

.PHONY: check-provisioning
check-provisioning:
	cd $(CURDIR)/spec/provisioning && \
	(bundle check || bundle install) && \
	bundle exec rspec

.PHONY: test
test: spec check-libraries

release: gon.hcl bin/mstrap
	mkdir -p ./dist
	gon -log-level=debug ./gon.hcl

.PHONY: install
install: bin/mstrap
	mkdir -p $(PREFIX)/bin
	cp ./bin/mstrap* $(PREFIX)/bin

.PHONY: reinstall
reinstall: bin/mstrap
	cp ./bin/mstrap* $(MSTRAP_BIN) -rf

vendor/libcrypto.a: $(OPENSSL_LIB_PATH)/libcrypto.a
	mkdir -p $(OPENSSL_LIB_PATH)
	cp -f $(OPENSSL_LIB_PATH)/libcrypto.a $(STATIC_LIBS_DIR)

vendor/libevent.a: $(LIBEVENT_LIB_PATH)/libevent.a
	mkdir -p $(STATIC_LIBS_DIR)
	cp -f $(LIBEVENT_LIB_PATH)/libevent.a $(STATIC_LIBS_DIR)

vendor/libpcre.a: $(LIBPCRE_LIB_PATH)/libpcre.a
	mkdir -p $(STATIC_LIBS_DIR)
	cp -f $(LIBPCRE_LIB_PATH)/libpcre.a $(STATIC_LIBS_DIR)

vendor/libssl.a: $(OPENSSL_LIB_PATH)/libssl.a
	mkdir -p $(OPENSSL_LIB_PATH)
	cp -f $(OPENSSL_LIB_PATH)/libssl.a $(STATIC_LIBS_DIR)
