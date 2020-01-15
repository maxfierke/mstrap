require "baked_file_system"
require "colorize"
require "ecr"
require "file_utils"
require "hcl"
require "http/client"
require "json"
require "logger"
require "openssl"
require "option_parser"
require "readline"
require "uri"
require "yaml"

require "./mstrap/paths"
require "./mstrap/utils/**"
require "./mstrap/version"
require "./mstrap/cli_options"
require "./mstrap/def"
require "./mstrap/defs/**"
require "./mstrap/ca_cert_installer"
require "./mstrap/profile_fetcher"
require "./mstrap/user"
require "./mstrap/configuration"
require "./mstrap/fs"
require "./mstrap/web_bootstrapper"
require "./mstrap/runtime"
require "./mstrap/runtimes/**"
require "./mstrap/project"
require "./mstrap/step"
require "./mstrap/templates/**"
require "./mstrap/steps/**"
require "./mstrap/bootstrapper"

# Defines top-level constants and shared utilities
module MStrap
  @@log_formatter : Logger::Formatter? = nil
  @@logger : Logger? = nil
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

  # :nodoc:
  def self.log_formatter
    @@log_formatter ||= Logger::Formatter.new do |severity, datetime, progname, message, io|
      if io.tty?
        io << message
      else
        label = severity.unknown? ? "ANY" : severity.to_s
        io << "[" << datetime << " PID#" << Process.pid << "] "
        io << label.rjust(5) << " -- : " << message
      end
    end.not_nil!
  end

  # Returns a `Logger` instance that can be used to log to the mstrap log file.
  # When `MStrap.debug?` is set to `true`, this also logs messages to `STDOUT`.
  def self.logger
    @@logger ||= if debug?
                   FileUtils.mkdir_p(Paths::RC_DIR, 0o755)
                   log_file = File.new(MStrap::Paths::LOG_FILE, "a+")
                   writer = IO::MultiWriter.new(log_file, STDOUT)
                   Logger.new(writer, level: Logger::DEBUG, formatter: log_formatter)
                 else
                   FileUtils.mkdir_p(Paths::RC_DIR, 0o755)
                   file = File.new(MStrap::Paths::LOG_FILE, "a+")
                   Logger.new(file, level: Logger::INFO, formatter: log_formatter)
                 end.not_nil!
  end

  # Returns a TLS client that uses a local version of the cURL CA bundle.
  def self.tls_client
    OpenSSL::SSL::Context::Client.new.tap do |client|
      client.ca_certificates = Paths::CA_CERT_BUNDLE
    end
  end
end
