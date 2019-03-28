CRYSTAL_BIN ?= $(shell which crystal)
SHARDS_BIN  ?= $(shell which shards)
MSTRAP_BIN ?= $(shell which mstrap)
BDWGC_LIB_PATH    ?= $(shell pkg-config --libs-only-L bdw-gc | cut -c 3-)
LIBEVENT_LIB_PATH ?= $(shell pkg-config --libs-only-L libevent | cut -c 3-)
LIBPCRE_LIB_PATH  ?= $(shell pkg-config --libs-only-L libpcre | cut -c 3-)
LIBYAML_LIB_PATH  ?= $(shell pkg-config --libs-only-L yaml-0.1 | cut -c 3-)
OPENSSL_LIB_PATH  ?= $(shell brew --prefix)/opt/openssl/lib
PREFIX      ?= /usr/local
RELEASE     ?=
STATIC      ?=
STATIC_LIBS_DIR = $(CURDIR)/vendor
SOURCES      = src/*.cr src/**/*.cr

override LDFLAGS += -L$(STATIC_LIBS_DIR)
override CRFLAGS += $(if $(RELEASE),--release ,--debug )$(if $(STATIC),--static )$(if $(LDFLAGS),--link-flags="$(LDFLAGS)" )

.PHONY: all
all: build

libs: vendor/libcrypto.a vendor/libevent.a vendor/libgc.a vendor/libpcre.a vendor/libssl.a vendor/libyaml.a

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

.PHONY: clean
clean:
	rm -f ./bin/mstrap*
	rm -rf ./dist

.PHONY: test
test: deps $(SOURCES)
	$(CRYSTAL_BIN) spec

.PHONY: spec
spec: test

.PHONY: install
install: bin/mstrap bin/mstrap-project
	mkdir -p $(PREFIX)/bin
	cp ./bin/mstrap* $(PREFIX)/bin

.PHONY: reinstall
reinstall: bin/mstrap bin/mstrap-project
	cp ./bin/mstrap* $(MSTRAP_BIN) -rf

vendor/libcrypto.a:
	mkdir -p $(STATIC_LIBS_DIR)
	cp -f $(OPENSSL_LIB_PATH)/libcrypto.a $(STATIC_LIBS_DIR)

vendor/libevent.a:
	mkdir -p $(STATIC_LIBS_DIR)
	cp -f $(LIBEVENT_LIB_PATH)/libevent.a $(STATIC_LIBS_DIR)

vendor/libgc.a:
	mkdir -p $(STATIC_LIBS_DIR)
	cp -f $(BDWGC_LIB_PATH)/libgc.a $(STATIC_LIBS_DIR)

vendor/libpcre.a:
	mkdir -p $(STATIC_LIBS_DIR)
	cp -f $(LIBPCRE_LIB_PATH)/libpcre.a $(STATIC_LIBS_DIR)

vendor/libssl.a:
	mkdir -p $(STATIC_LIBS_DIR)
	cp -f $(OPENSSL_LIB_PATH)/libssl.a $(STATIC_LIBS_DIR)

vendor/libyaml.a:
	mkdir -p $(STATIC_LIBS_DIR)
	cp -f $(LIBYAML_LIB_PATH)/libyaml.a $(STATIC_LIBS_DIR)
