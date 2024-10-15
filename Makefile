MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

-include Makefile.local

CODESIGN_IDENTITY ?=
CRFLAGS           ?=
CRYSTAL           ?= $(shell which crystal)
HOST_ARCH         := $(shell uname -m)
HOST_OS           := $(shell uname -s | tr '[:upper:]' '[:lower:]')
MESON             ?= $(shell which meson)
PREFIX            ?= /usr/local
RELEASE           ?=
SHARDS            ?= $(shell which shards)
SKIP_CODESIGN     ?=
SKIP_NOTARIZE     ?=
STATIC            ?=
STRIP_RPATH       ?=
SOURCES           := src/*.cr src/**/*.cr
TAG_NAME          ?= $(shell git describe --tags)
TARGET_ARCH       ?= $(HOST_ARCH)
TARGET_CABI       ?=
TARGET_OS         ?= $(HOST_OS)
TARGET_TRIPLE     ?= $(TARGET_OS)-$(TARGET_ARCH)$(if $(TARGET_CABI),-$(TARGET_CABI),)

TARGET_BUILD_DIR  ?= .build/$(TARGET_TRIPLE)
TARGET_CROSS_FILE ?= config/$(TARGET_TRIPLE).ini
TARGET_DIST_PATH  ?= dist/mstrap-$(TAG_NAME)-$(subst -,_,$(TARGET_TRIPLE)).zip

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

dist/mstrap.zip: bin/mstrap codesign
	@mkdir -p dist
	zip --junk-paths dist/mstrap.zip bin/mstrap

.PHONY: build
build: bin/mstrap

.PHONY: codesign
codesign: bin/mstrap
	@if [ "$(TARGET_OS)" == "darwin" ] && [ -z "$(SKIP_CODESIGN)" ]; then \
		codesign -f -v \
			--timestamp \
			--options runtime \
			--entitlements "macos-entitlements.plist" \
			-s "$(CODESIGN_IDENTITY)" \
			bin/mstrap; \
	fi

.PHONY: notarize
notarize: dist/mstrap.zip
	@if [ "$(TARGET_OS)" == "darwin" ] && [ -z "$(SKIP_NOTARIZE)" ]; then \
		xcrun notarytool submit \
			--keychain-profile "mstrap" \
			--wait \
			dist/mstrap.zip; \
	fi

.PHONY: deps
deps: shard.yml shard.lock
	$(SHARDS) check || $(SHARDS) install

docs: $(SOURCES)
	$(CRYSTAL) docs

.PHONY: format
format:
	$(CRYSTAL) tool format

.PHONY: lint
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
	$(CRYSTAL) spec $(CRFLAGS) -Dmt_no_expectations --error-trace

.PHONY: check-formatting
check-formatting: $(SOURCES)
	$(CRYSTAL) tool format --check

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
test: check-formatting spec check-libraries

.PHONY: release
release: dist/mstrap.zip notarize
	@mv dist/mstrap.zip $(TARGET_DIST_PATH)
	echo "Release zip saved to $(TARGET_DIST_PATH)"

.PHONY: smoke-test
smoke-test: $(TARGET_BUILD_DIR)/mstrap
	BUILD_DIR=$(TARGET_BUILD_DIR) \
	TEST_NAME=$(TEST_NAME) \
	$(CURDIR)/spec/provisioning/test.sh

.PHONY: install
install: $(TARGET_BUILD_DIR)/mstrap $(TARGET_BUILD_DIR)/build.ninja meson.build
	$(MESON) install -C $(TARGET_BUILD_DIR) --tags runtime
