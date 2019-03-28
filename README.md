# mstrap

TODO: Write a description here

## Installation

TODO: Write installation instructions here

## Usage

TODO: Write usage instructions here

## Development

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
