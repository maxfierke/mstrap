# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - 20XX-XX-XX

### Added

- Support for using [mise](https://mise.jdx.dev) to manage language runtime versions (#50, #53). `config.hcl` can be configured as such to enable it:
  ```
  version = "1.1"

  # ...

  runtimes {
    default_manager = "mise"
  }
  ```

  To switch, you'll need to re-run `mstrap` and restart your terminal windows.
  Then, you can run `brew uninstall asdf --force` to uninstall asdf (`mstrap`
  will have removed `asdf`'s activation from mstrap's `env.sh` already)

### Changed

### Bugfixes

### Removed

- Fix deprecation warning in newer Docker Compose versions caused by version property in `~/.mstrap/services-internal.yml`

## [0.6.0] - 2023-10-15

### Added

- Install Docker Buildkit plugin (dockerx) by default (#43)

### Changed

- **[Breaking]**: Updated Docker compose CLI usage to v2 (i.e. `docker-compose` to `docker compose`)
  Requires the Docker Compose v2 plugin for Docker CLI, which has been installed
  and active by default since late 2022 in Docker Desktop. (#43)
- [ci] Add Archlinux x86_64, Fedora 37 x86_64, and Fedora 38 x86_64 to CI, bumping them up into Tier 1 platform support
- Updated Crystal to 1.10.1
- Updated openssl wrap to 3.0.8-1
- Updated zlib wrap to 1.3-4

### Bugfixes

- Workaround noisy warnings from new linker on Xcode 15.0+

### Removed

- Removed Docker install support for old Fedora versions (< 37) (#43)

## [0.5.2] - 2023-04-19

### Added

### Changed

- Switched to PCRE2 instead of PCRE for regular expressions (which is EOL)
- Updated bundled wraps for OpenSSL and zlib (affects source compiling only)

### Bugfixes

- Fixed asdf global version selection when current version is latest

### Removed

- Drop support for macOS < 12 (might still work, but no longer testing)

## [0.5.1] - 2022-11-01

### Changed

- Nothing changed, just new builds with OpenSSL 3.0.7 to address CVEs

## [0.5.0] - 2022-10-27

### Added

- Added support for Apple Silicon and easier cross-compilation ([#35](https://github.com/maxfierke/mstrap/pull/35))
- Added support for Arch Linux and Manjaro ([#36](https://github.com/maxfierke/mstrap/pull/36))
- Added support for projects syncing with upstream repos ([#38](https://github.com/maxfierke/mstrap/pull/38))
- Added support for Crystal projects via asdf-crystal ([#40](https://github.com/maxfierke/mstrap/pull/40))

### Changed

- mstrap no longer requires a two-step initial bootstrapping process with a shell
  restart in between during its first run. A shell/terminal restart is still necessary
  afterwards, however.

### Bugfixes

- Handle invalid URIs for project repos ([#38](https://github.com/maxfierke/mstrap/pull/38), fixes [#37](https://github.com/maxfierke/mstrap/issues/37))

### Removed

- Dropped support for Fedora 32 ([#36](https://github.com/maxfierke/mstrap/pull/36))
- Stopped installing Bundler < 2 for Ruby projects

## [0.4.0] - 2021-06-03

### Changed

- mstrap now asks before re-writing existing configuration with a new, remote
  configuration.
- Default Brewfile now only installs GNU coreutils and related tools on macOS, as
  it's assumed Linux distros will have reasonably recent versions.
- NSS library is only installed if mkcert gets used by mstrap

### Removed

- Dropped support for compiling under Crystal < 1.0.0
- Removed unnecessary dependencies in Brewfile

## [0.3.1] - 2021-03-28

### Fixed

* Fixed Alpine builds in CI to unblock binary Linux releases

## [0.3.0] - 2021-03-28

### Added

- Support for Go via asdf ([#26](https://github.com/maxfierke/mstrap/pull/26))
- Support reading runtime versions from project `.tool-versions` ([#29](https://github.com/maxfierke/mstrap/pull/29))

### Changed

- Compiling mstrap under Crystal 1.0.0 ([#31](https://github.com/maxfierke/mstrap/pull/31))

### Fixed

- Fix excessive reshimming during batch npm/yarn installs ([#27](https://github.com/maxfierke/mstrap/pull/27))
- Fix excessive logging verbosity on sub-step runs ([#28](https://github.com/maxfierke/mstrap/pull/28))
- Fix cURL CA cert fetching ([#31](https://github.com/maxfierke/mstrap/pull/31))

## [0.2.8] - 2021-01-16

### Added

- Support for Rust via asdf ([#23](https://github.com/maxfierke/mstrap/pull/23))
- Support for projects and profiles using a branch other than `master` as the
  default branch, e.g. `main`, etc. ([#24](https://github.com/maxfierke/mstrap/pull/24))

## [0.2.7] - 2020-12-07

### Added

- Everything! First public release.

[Unreleased]: https://github.com/maxfierke/mstrap/compare/v0.6.0...HEAD
[0.6.0]: https://github.com/maxfierke/mstrap/compare/v0.5.2...v0.6.0
[0.5.2]: https://github.com/maxfierke/mstrap/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.com/maxfierke/mstrap/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/maxfierke/mstrap/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/maxfierke/mstrap/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/maxfierke/mstrap/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/maxfierke/mstrap/compare/v0.2.9...v0.3.0
[0.2.9]: https://github.com/maxfierke/mstrap/compare/v0.2.8...v0.2.9
[0.2.8]: https://github.com/maxfierke/mstrap/compare/v0.2.7...v0.2.8
[0.2.7]: https://github.com/maxfierke/mstrap/releases/tag/v0.2.7
