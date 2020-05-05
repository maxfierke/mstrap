MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

CRYSTAL_BIN       ?= $(shell which crystal)
SHARDS_BIN        ?= $(shell which shards)
MSTRAP_BIN        ?= $(shell which mstrap)
PREFIX            ?= /usr/local
RELEASE           ?=
STATIC            ?=
STATIC_LIBS_DIR   := $(CURDIR)/vendor
SOURCES           := src/*.cr src/**/*.cr
UNAME_S           := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
  override LDFLAGS += -L$(STATIC_LIBS_DIR)
  export MACOSX_DEPLOYMENT_TARGET=10.12
  LIBEVENT_LIB_PATH ?= $(shell pkg-config --libs-only-L libevent | cut -c 3-)
  LIBPCRE_LIB_PATH  ?= $(shell pkg-config --libs-only-L libpcre | cut -c 3-)
  OPENSSL_LIB_PATH ?= $(shell brew --prefix openssl@1.1)/lib
  export PKG_CONFIG_PATH=$(OPENSSL_LIB_PATH)/pkgconfig

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

  .PHONY: libs
  libs: vendor/libcrypto.a vendor/libssl.a vendor/libevent.a vendor/libpcre.a
else
  .PHONY: libs
  libs:
endif

override CRFLAGS += --progress $(if $(RELEASE),--release ,--debug --error-trace )$(if $(STATIC),--static )$(if $(LDFLAGS),--link-flags="$(LDFLAGS)" )

.PHONY: all
all: build

bin/mstrap: deps libs $(SOURCES)
	mkdir -p bin
	@if [ "$(STATIC)" -eq 1 ] && [ "$(UNAME_S)" == "Linux" ]; then \
		DOCKER_BUILDKIT=1 docker build -t mstrap-static-builder .; \
		docker run --rm -it -v $(CURDIR):/workspace -w /workspace mstrap-static-builder:latest \
			crystal build -o bin/mstrap src/cli.cr $(CRFLAGS); \
	else \
		$(CRYSTAL_BIN) build -o bin/mstrap src/cli.cr $(CRFLAGS); \
	fi
	@if readelf -p1 bin/mstrap | grep -q 'linuxbrew'; then \
		patchelf --remove-rpath bin/mstrap; \
		patchelf --set-interpreter /lib64/ld-linux-x86-64.so.2 bin/mstrap; \
	fi

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
	@[ "$$(uname -s)" == "Darwin" ] && rm -rf ./vendor/*.a || true

.PHONY: spec
spec: libs deps $(SOURCES)
	$(CRYSTAL_BIN) tool format --check
	@if [ "$$(uname -s)" == "Darwin" ]; then \
		# crystal spec doesn't support link-flags: https://github.com/crystal-lang/crystal/issues/6231 \
		LIBRARY_PATH=$(STATIC_LIBS_DIR) $(CRYSTAL_BIN) spec -Dmt_no_expectations; \
	else \
		$(CRYSTAL_BIN) spec -Dmt_no_expectations; \
	fi

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
