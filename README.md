# mstrap

mstrap (short for "**m**achine boot**strap**") is a tool for provisioning and managing a development environment.
It is a [convention-over-configuration](https://en.wikipedia.org/wiki/Convention_over_configuration)
tool, which aims to leverage existing ecosystem tools to provide a one-command provisioning
experience for a new machine.

The approach is inspired by the [`chirpstrap`](https://medium.com/intensive-code-unit/provisioning-engineers-with-chirpstrap-ecae874453d0) tool built at Iora Health, but is built and maintained in my personal capacity and is not associated with Iora Health.

### Aims

* Run on a new machine with no development tools installed
* Leverage existing ecosystem tools, when possible
  * Avoid vendoring or overriding tool defaults
* Hook into standard [scripts-to-rule-them-all](https://github.com/github/scripts-to-rule-them-all)
  * Currently hooks into a project's `script/bootstrap` and `script/setup`
* Eventually leverage `mruby` for user-defined extensions written in Ruby, such
  as environment migrations.

#### Platform Support

Because `mstrap` leverages Homebrew extensively, the aim is to eventually support
the same platforms officially supported by Homebrew:

* [X] macOS
* [ ] Linux _(planned)_
* [ ] WSL2 (Windows Subsystem for Linux) _(planned)_

#### Language Runtime Support

`mstrap` comes with built-in support for bootstrapping projects in a number of
different language runtimes, including support for installing project-specific
runtime versions and installing dependencies, via [ASDF](https://asdf-vm.com).

Current support:

* [X] JavaScript
* [X] PHP
* [X] Python
* [X] Ruby

Planned:

* [ ] .NET
* [ ] Elixir
* [ ] Go
* [ ] Rust

Bootstrapping other runtimes, while not directly supported, can still be done
through a project's `script/bootstrap` or `script/setup`.

## Installation

0. Follow steps in [Development](#Development) to get development dependencies
   installed.
1. `make`
2. `make install` or `sudo make install`, depending on your access rights to
   `/usr/local/bin`. You may also specify `PREFIX` to install to a different location.

## Usage

On a new machine, run `mstrap` to run the whole suite.

`mstrap --help` provides details on configuration options and commands.

`mstrap steps` will list the available steps. These can each be run individually,
e.g. `mstrap projects` to just install/update configured projects.

```
Usage: mstrap [options] <command> -- [<arguments>]
    -d, --debug                      Run with debug messaging
    -f, --force                      Force overwrite of existing config with reckless abandon
    -c, --config-path [CONFIG_PATH]  Path to configuration file
                                     Default: $HOME/.mstrap/config.yml. Can also be an HTTPS URL.
    -n, --name NAME                  Your name (Default: config or prompt)
                                     Can also be specified by MSTRAP_USER_NAME env var.
    -e, --email EMAIL ADDRESS        Email address (Default: config or prompt)
                                     Can also be specified by MSTRAP_USER_EMAIL env var.
    -g, --github GITHUB              GitHub username (Default: config or prompt)
                                     Can also be specified by MSTRAP_USER_GITHUB env var.
    -a, --github-access-token [GITHUB_ACCESS_TOKEN]
                                     GitHub access token
                                     Can also be specified by MSTRAP_GITHUB_ACCESS_TOKEN env var.
                                     Required for automatic fetching of personal dotfiles and Brewfile
                                     Can be omitted. Will pull from `hub` config, if available.
    --skip-migrations                Skip migrations
    --skip-project-update            Skip auto-update of projects
    --skip-update                    Skip auto-update of mstrap
    -v, --version                    Show version
    -h, --help                       Show this message

COMMANDS
    compose              Wrapper around `docker-compose -f /Users/mfierke/.mstrap/services.yml`
    debug                Prints debug information
    dependencies         Basic machine bootstrapping with strap.sh, hub, and brew bundle.
    init                 Initializes /Users/mfierke/.mstrap
    node                 Set default global Node version and installs global NPM packages
    projects             Bootstraps configured projects
    python               Set default global Python version and installs global pip packages
    ruby                 Set default global Ruby version and installs global Ruby gems
    services             (Re)creates mstrap-managed docker-compose services
    shell                Injects mstrap's env.sh into the running shell's config
    steps                Prints available steps

Running mstrap without a command will do a full bootstrap.
```

## Development

1. `git clone git@github.com:maxfierke/mstrap.git`
2. `brew install crystal-lang`
3. `make`
4. `bin/mstrap` and `bin/mstrap-project` will be created

### Error about libssl and/or libcrypto on macOS Mojave 10.14

For some unknown reason, using `-L` with the linker on Mojave seems to cause it
to not find where `libssl` or `libcrypto` are. You can fix this by (re-)installing
the headers for macOS 10.14 from the XCode command-line tools:

```sh
$ sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /
```

I don't know why this works.

## Contributing

1. Fork it (<https://github.com/maxfierke/mstrap/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Max Fierke](https://github.com/maxfierke) - creator and maintainer
