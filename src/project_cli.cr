require "./mstrap"
require "./mstrap/project_cli"

Colorize.on_tty_only!
MStrap::ProjectCLI.run!(ARGV)
