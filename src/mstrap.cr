require "colorize"
require "ecr"
require "file_utils"
require "hcl"
require "http/client"
require "json"
require "log"
require "openssl"
require "option_parser"
require "readline"
require "uri"
require "yaml"

require "./mstrap/version"
require "./mstrap/paths"
require "./mstrap/utils/**"
require "./mstrap/platform/**"
require "./mstrap/cli_options"
require "./mstrap/def"
require "./mstrap/defs/**"
require "./mstrap/ca_cert_installer"
require "./mstrap/profile_fetcher"
require "./mstrap/user"
require "./mstrap/configuration"
require "./mstrap/docker"
require "./mstrap/web_bootstrapper"
require "./mstrap/runtime"
require "./mstrap/runtimes/**"
require "./mstrap/project"
require "./mstrap/step"
require "./mstrap/templates/**"
require "./mstrap/steps/**"

# Defines top-level constants and shared utilities
module MStrap
  Log          = ::Log.for(self)
  LogFormatter = ::Log::Formatter.new do |entry, io|
    if io.tty?
      io << entry.message
    else
      label = entry.severity.none? ? "ANY" : entry.severity.to_s
      io << "[" << entry.timestamp << " PID#" << Process.pid << "] "
      io << label.rjust(5) << " -- : " << entry.message
    end
  end

  @@debug = false

  # Set debug mode for `mstrap`
  def self.debug=(value)
    @@debug = value
  end

  # Returns whether or not `mstrap` is in debug mode.
  #
  # NOTE: This is not the same as whether it was _compiled_ in debug mode.
  def self.debug?
    @@debug
  end

  # Returns whether or not the feature passed for *name* is active.
  def self.has_feature?(name)
    !!ENV["MSTRAP_FEAT_#{name.upcase}"]?
  end

  # Sets up Log instance that can be used to log to the mstrap log file.
  # When `MStrap.debug?` is set to `true`, this also logs messages to `STDOUT`.
  def self.initialize_logger! : Nil
    if debug?
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

  # Returns a TLS client that uses a local version of the cURL CA bundle.
  def self.tls_client
    OpenSSL::SSL::Context::Client.new.tap do |client|
      client.ca_certificates = Paths::CA_CERT_BUNDLE
    end
  end
end
