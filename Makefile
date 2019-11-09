CRYSTAL_BIN ?= $(shell which crystal)
SHARDS_BIN  ?= $(shell which shards)
MSTRAP_BIN ?= $(shell which mstrap)
BDWGC_LIB_PATH    ?= $(shell pkg-config --libs-only-L bdw-gc | cut -c 3-)
LIBEVENT_LIB_PATH ?= $(shell pkg-config --libs-only-L libevent | cut -c 3-)
LIBPCRE_LIB_PATH  ?= $(shell pkg-config --libs-only-L libpcre | cut -c 3-)
LIBYAML_LIB_PATH  ?= $(shell pkg-config --libs-only-L yaml-0.1 | cut -c 3-)
LIBSSL_LIB_PATH   ?= $(shell brew --prefix openssl)/lib
PREFIX      ?= /usr/local
RELEASE     ?=
STATIC      ?=
STATIC_LIBS_DIR = $(CURDIR)/vendor
SOURCES      = src/*.cr src/**/*.cr

override LDFLAGS += -L$(STATIC_LIBS_DIR)
override CRFLAGS += $(if $(RELEASE),--release ,--debug --error-trace )$(if $(STATIC),--static )$(if $(LDFLAGS),--link-flags="$(LDFLAGS)" )

.PHONY: all
all: build

libs: vendor/libcrypto.a vendor/libssl.a vendor/libevent.a vendor/libgc.a vendor/libpcre.a vendor/libyaml.a

bin/mstrap: deps libs $(SOURCES)
	mkdir -p bin
	$(CRYSTAL_BIN) build -o bin/mstrap src/cli.cr $(CRFLAGS)

bin/mstrap-project: deps libs $(SOURCES)
	mkdir -p bin
	$(CRYSTAL_BIN) build -o bin/mstrap-project src/project_cli.cr $(CRFLAGS)

.PHONY: build
build: bin/mstrap bin/mstrap-project

.PHONY: deps
deps: shard.yml shard.lock
	$(SHARDS_BIN) check || $(SHARDS_BIN) install

docs: $(SOURCES)
	$(CRYSTAL_BIN) docs

.PHONY: clean
clean:
	rm -f ./bin/mstrap*
	rm -rf ./dist
	rm -rf ./docs
	rm -rf ./vendor/*.a

.PHONY: spec
spec: libs deps $(SOURCES)
	# crystal spec doesn't support link-flags: https://github.com/crystal-lang/crystal/issues/6231
	LIBRARY_PATH=$(STATIC_LIBS_DIR) $(CRYSTAL_BIN) spec -Dmt_no_expectations

.PHONY: check-libraries
check-libraries: bin/mstrap
	@if [ "$$(otool -LX bin/mstrap | awk '{print $$1}')" != "$$(cat expected.libs)" ]; then \
		echo "FAIL: bin/mstrap has non-allowed dynamic libraries"; \
		exit 1; \
	else \
		echo "OK: bin/mstrap has only allowed dynamic libraries"; \
		exit 0; \
	fi

.PHONY: test
test: spec check-libraries

.PHONY: install
install: bin/mstrap bin/mstrap-project
	mkdir -p $(PREFIX)/bin
	cp ./bin/mstrap* $(PREFIX)/bin

.PHONY: reinstall
reinstall: bin/mstrap bin/mstrap-project
	cp ./bin/mstrap* $(MSTRAP_BIN) -rf

vendor/libcrypto.a: $(LIBSSL_LIB_PATH)/libcrypto.a
	mkdir -p $(LIBSSL_LIB_PATH)
	cp -f $(LIBSSL_LIB_PATH)/libcrypto.a $(STATIC_LIBS_DIR)

vendor/libevent.a: $(LIBEVENT_LIB_PATH)/libevent.a
	mkdir -p $(STATIC_LIBS_DIR)
	cp -f $(LIBEVENT_LIB_PATH)/libevent.a $(STATIC_LIBS_DIR)

vendor/libgc.a: $(BDWGC_LIB_PATH)/libgc.a
	mkdir -p $(STATIC_LIBS_DIR)
	cp -f $(BDWGC_LIB_PATH)/libgc.a $(STATIC_LIBS_DIR)

vendor/libpcre.a: $(LIBPCRE_LIB_PATH)/libpcre.a
	mkdir -p $(STATIC_LIBS_DIR)
	cp -f $(LIBPCRE_LIB_PATH)/libpcre.a $(STATIC_LIBS_DIR)

vendor/libssl.a: $(LIBSSL_LIB_PATH)/libssl.a
	mkdir -p $(LIBSSL_LIB_PATH)
	cp -f $(LIBSSL_LIB_PATH)/libssl.a $(STATIC_LIBS_DIR)

vendor/libyaml.a: $(LIBYAML_LIB_PATH)/libyaml.a
	mkdir -p $(STATIC_LIBS_DIR)
	cp -f $(LIBYAML_LIB_PATH)/libyaml.a $(STATIC_LIBS_DIR)
