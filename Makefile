MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

CRFLAGS           ?=
CRYSTAL           ?= $(shell which crystal)
SHARDS            ?= $(shell which shards)
MESON             ?= $(shell which meson)
GON_CONFIG        ?= ./gon.hcl
HOST_ARCH         := $(shell uname -m)
HOST_OS           := $(shell uname -s | tr '[:upper:]' '[:lower:]')
PREFIX            ?= /usr/local
RELEASE           ?=
STATIC            ?=
STRIP_RPATH       ?=
SOURCES           := src/*.cr src/**/*.cr
SKIP_NOTARIZE     ?=
TAG_NAME          ?= $(shell git describe --tags)
TARGET_ARCH       ?= $(HOST_ARCH)
TARGET_CABI       ?=
TARGET_OS         ?= $(HOST_OS)

TARGET_TRIPLE     ?= $(TARGET_OS)-$(TARGET_ARCH)$(if $(TARGET_CABI),-$(TARGET_CABI),)
TARGET_BUILD_DIR  ?= .build/$(TARGET_TRIPLE)
TARGET_CROSS_FILE ?= config/$(TARGET_TRIPLE).ini

# Force static compilation on musl
ifeq ($(TARGET_CABI),musl)
  override STATIC=1
endif

MESON_FLAGS ?= \
  --prefix=$(PREFIX) \
  -Dcrystal=$(CRYSTAL) \
  -Dshards=$(SHARDS) \
  $(if $(RELEASE),--buildtype=release --strip,--buildtype=debug) \
  $(if $(STATIC),--default-library=static,--default-library=shared)

ifeq ($(shell command -v xcodebuild > /dev/null && echo true),true)
  XCODE_VERSION := $(shell xcodebuild -version | awk '/Xcode/ {print $$2}' | tr -d '')

  # Use legacy linker with xcode 15 for now
  ifeq ($(XCODE_VERSION),15.0)
    override CRFLAGS += --link-flags=-Wl,-ld_classic
  endif
endif

# Add cross-files if target and host are different
ifeq ($(shell [[ "$(TARGET_OS)" != "$(HOST_OS)" || "$(TARGET_ARCH)" != "$(HOST_ARCH)" || ! -z "$(TARGET_CABI)" ]] && echo true),true)
  override MESON_FLAGS += --cross-file=$(TARGET_CROSS_FILE)
else
  # Do some special stuff on macOS
  ifeq ($(shell [[ "$(TARGET_OS)" == "$(HOST_OS)" && "$(TARGET_OS)" == "darwin" ]] && echo true),true)
    ifeq ($(shell command -v brew > /dev/null && echo true),true)
      ifeq ($(shell brew ls --versions openssl@3 > /dev/null && echo true),true)
        export PKG_CONFIG_PATH=$(shell brew --prefix openssl@3)/lib/pkgconfig
        override MESON_FLAGS += --pkg-config-path=$(PKG_CONFIG_PATH)
      else ifeq ($(shell brew ls --versions openssl@1.1 > /dev/null && echo true),true)
        export PKG_CONFIG_PATH=$(shell brew --prefix openssl@1.1)/lib/pkgconfig
        override MESON_FLAGS += --pkg-config-path=$(PKG_CONFIG_PATH)
      endif
    endif
  endif
endif

.PHONY: all
all: build

$(TARGET_BUILD_DIR)/build.ninja: meson.build $(TARGET_CROSS_FILE)
	@if [ ! -z "$(MESON)" ]; then \
		mkdir -p $(TARGET_BUILD_DIR); \
		if [ -f "$@" ]; then \
			$(MESON) setup $(MESON_FLAGS) --reconfigure $(TARGET_BUILD_DIR); \
		else \
			$(MESON) setup $(MESON_FLAGS) $(TARGET_BUILD_DIR); \
		fi; \
	else \
		echo "FAIL: meson must be installed"; \
		exit 1; \
	fi

$(TARGET_BUILD_DIR)/mstrap: $(SOURCES) $(TARGET_BUILD_DIR)/build.ninja
	@if [ ! -z "$(MESON)" ]; then \
		$(MESON) compile -v -C $(TARGET_BUILD_DIR); \
	else \
		echo "FAIL: meson must be installed"; \
		exit 1; \
	fi

bin/mstrap: $(TARGET_BUILD_DIR)/mstrap
	mkdir -p bin
	cp $(TARGET_BUILD_DIR)/mstrap bin/mstrap
	@if [ ! -z "$(STRIP_RPATH)" ] && [ "$(TARGET_OS)" == "linux" ] && readelf -p1 bin/mstrap | grep -q 'linuxbrew'; then \
		patchelf --remove-rpath bin/mstrap; \
		patchelf --set-interpreter /lib64/ld-linux-x86-64.so.2 bin/mstrap; \
	fi

.PHONY: build
build: bin/mstrap

.PHONY: deps
deps: shard.yml shard.lock
	$(SHARDS) check || $(SHARDS) install

docs: $(SOURCES)
	$(CRYSTAL) docs

format:
	$(CRYSTAL) tool format

lint: deps
	$(CRYSTAL) run $(CRFLAGS) bin/ameba.cr

.PHONY: clean
clean:
	rm -f ./bin/mstrap*
	rm -rf ./dist
	rm -rf ./docs
	rm -rf ./.build

.PHONY: spec
spec: deps $(SOURCES)
	$(CRYSTAL) tool format --check
	$(CRYSTAL) spec $(CRFLAGS) -Dmt_no_expectations --error-trace

.PHONY: check-libraries
check-libraries: bin/mstrap
	@if [ ! -z "$(STATIC)" ] && [ "$(TARGET_OS)" == "darwin" ] && [ "$$(otool -LX bin/mstrap | awk '{print $$1}')" != "$$(cat expected.libs.darwin)" ]; then \
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
	@if [ "$(TARGET_OS)" == "darwin" ] && [ -z "$(SKIP_NOTARIZE)" ]; then \
		gon -log-level=debug $(GON_CONFIG); \
	else \
		zip --junk-paths dist/mstrap.zip bin/mstrap; \
	fi
	@if [ ! -z "$(TAG_NAME)" ]; then \
		mv dist/mstrap.zip dist/mstrap-$(TAG_NAME)-$(subst -,_,$(TARGET_TRIPLE)).zip; \
	fi

.PHONY: smoke-test
smoke-test: $(TARGET_BUILD_DIR)/mstrap
	BUILD_DIR=$(TARGET_BUILD_DIR) \
	TEST_NAME=$(TEST_NAME) \
	$(CURDIR)/spec/provisioning/test.sh

.PHONY: install
install: $(TARGET_BUILD_DIR)/mstrap $(TARGET_BUILD_DIR)/build.ninja meson.build
	$(MESON) install -C $(TARGET_BUILD_DIR) --tags runtime
