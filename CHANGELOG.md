# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[Unreleased]: https://github.com/maxfierke/mstrap/compare/v0.2.8...HEAD
[0.2.8]: https://github.com/maxfierke/mstrap/compare/v0.2.7...v0.2.8
[0.2.7]: https://github.com/maxfierke/mstrap/releases/tag/v0.2.7
