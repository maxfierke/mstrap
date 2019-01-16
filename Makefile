CRYSTAL_BIN ?= $(shell which crystal)
SHARDS_BIN  ?= $(shell which shards)
MSTRAP_BIN ?= $(shell which mstrap)
PREFIX      ?= /usr/local
RELEASE     ?=
STATIC      ?=
SOURCES      = src/*.cr src/**/*.cr

override CRFLAGS += $(if $(RELEASE),--release ,--debug )$(if $(STATIC),--static )$(if $(LDFLAGS),--link-flags="$(LDFLAGS)" )

.PHONY: all
all: build

bin/mstrap: deps $(SOURCES)
	mkdir -p bin
	$(CRYSTAL_BIN) build -o bin/mstrap src/cli.cr $(CRFLAGS)

bin/mstrap-project: deps $(SOURCES)
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
