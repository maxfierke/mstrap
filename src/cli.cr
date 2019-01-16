require "./mstrap"
require "./mstrap/cli"

Colorize.on_tty_only!
MStrap::CLI.run!(ARGV)
