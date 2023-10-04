# mstrap

mstrap (short for "**m**achine boot**strap**") is a tool for provisioning and managing a development environment.
It is a [convention-over-configuration](https://en.wikipedia.org/wiki/Convention_over_configuration)
tool, which aims to leverage existing ecosystem tools to provide a one-command provisioning
experience for a new machine.

The approach is inspired by the [`chirpstrap`](https://medium.com/intensive-code-unit/provisioning-engineers-with-chirpstrap-ecae874453d0) tool built at Iora Health,
but is built and maintained in my personal capacity and is not associated with
Iora Health.

## Aims

* Run on a new machine with no development tools installed
* Leverage existing ecosystem tools, when possible
  * Avoid vendoring or overriding tool defaults
* Hook into standard [scripts-to-rule-them-all](https://github.com/github/scripts-to-rule-them-all)
  * Currently hooks into a project's `script/bootstrap` and `script/setup`

`mstrap` is wholly centered around proving a no-runtime-dependency (other than
normal system libraries) approach and will always remain a tool designed around
being possible to run immediately after taking a new machine out of its box, and
finishing the OS setup.

## Installation & Usage

Please refer to the [documentation site](https://mstrap.dev) for documentation

## Development

1. Install dependencies
  * macOS: `brew install crystal meson libevent pcre2 openssl`
  * Debian/Ubuntu:
    1. [Install Crystal](https://crystal-lang.org/install/)
    2. `sudo apt install meson libevent-dev libpcre2-dev libssl-dev patchelf`
2. `git clone git@github.com:maxfierke/mstrap.git`
3. `make`
4. `bin/mstrap` will be created

## Contributing

1. Fork it (<https://github.com/maxfierke/mstrap/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Max Fierke](https://github.com/maxfierke) - creator and maintainer
