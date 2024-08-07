require "colorize"
require "ecr"
require "file_utils"
require "hcl"
require "http/client"
require "json"
require "log"
require "openssl"
require "option_parser"
require "term-prompt"
require "uri"
require "yaml"

require "./mstrap/version"
require "./mstrap/paths"
require "./mstrap/errors"
require "./mstrap/dsl/*"
require "./mstrap/dsl"
require "./mstrap/platform/*"
require "./mstrap/platform"
require "./mstrap/cli_options"
require "./mstrap/def"
require "./mstrap/defs/**"
require "./mstrap/profile_fetcher"
require "./mstrap/user"
require "./mstrap/configuration"
require "./mstrap/supports/**"
require "./mstrap/bootstrapper"
require "./mstrap/bootstrappers/**"
require "./mstrap/runtime_manager"
require "./mstrap/runtime_managers/**"
require "./mstrap/runtime"
require "./mstrap/runtimes/**"
require "./mstrap/project"
require "./mstrap/step"
require "./mstrap/templates/**"
require "./mstrap/steps/**"

# :nodoc:
module Term
  module Screen
    def size_from_readline
      # Always return default size to avoid linking to readline
      DEFAULT_SIZE
    end
  end
end

# Defines top-level constants and shared utilities
module MStrap
  Log          = ::Log.for("mstrap")
  LogFormatter = ::Log::Formatter.new do |entry, io|
    if io.tty?
      io << entry.message
    else
      label = entry.severity.none? ? "ANY" : entry.severity.to_s
      io << "[" << entry.timestamp << " PID#" << Process.pid << "] "
      io << label.rjust(5) << " -- : " << entry.message
    end
  end

  @@verbose = false

  # Set verbose mode for `mstrap`
  def self.verbose=(value)
    @@verbose = value
  end

  # Returns whether or not `mstrap` is in verbose mode.
  def self.verbose?
    @@verbose
  end

  # Sets up Log instance that can be used to log to the mstrap log file.
  # When `MStrap.verbose?` is set to `true`, this also logs messages to `STDOUT`.
  def self.initialize_logger! : Nil
    if verbose?
      FileUtils.mkdir_p(Paths::RC_DIR, 0o755)
      log_file = File.new(MStrap::Paths::LOG_FILE, "a+")
      writer = IO::MultiWriter.new(log_file, STDOUT)
      backend = ::Log::IOBackend.new(writer)
      backend.formatter = LogFormatter

      ::Log.builder.clear
      ::Log.builder.bind "*", :debug, backend
    else
      FileUtils.mkdir_p(Paths::RC_DIR, 0o755)
      file = File.new(MStrap::Paths::LOG_FILE, "a+")

      backend = ::Log::IOBackend.new(file)
      backend.formatter = LogFormatter

      ::Log.builder.clear
      ::Log.builder.bind "*", :info, backend
    end

    nil
  end

  # Returns whether or not the `mstrap` environment file (`env.sh`) has been
  # loaded into the environment.
  def self.mstrapped?
    ENV["MSTRAP"]? == "true"
  end

  # Returns a TLS client that uses a local version of the cURL CA bundle.
  def self.tls_client
    OpenSSL::SSL::Context::Client.new.tap do |client|
      client.ca_certificates = Paths::CA_CERT_BUNDLE
    end
  end
end
