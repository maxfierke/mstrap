require "baked_file_system"
require "colorize"
require "ecr"
require "file_utils"
require "http/client"
require "json"
require "logger"
require "option_parser"
require "readline"
require "uri"
require "yaml"

require "./mstrap/cli_options"
require "./mstrap/def"
require "./mstrap/defs/**"
require "./mstrap/user"
require "./mstrap/configuration"
require "./mstrap/fs"
require "./mstrap/paths"
require "./mstrap/version"
require "./mstrap/utils/**"
require "./mstrap/tracker"
require "./mstrap/web_bootstrapper"
require "./mstrap/project"
require "./mstrap/projects/**"
require "./mstrap/templates/**"
require "./mstrap/step"
require "./mstrap/steps/**"
require "./mstrap/bootstrapper"

module MStrap
  @@log_formatter : Logger::Formatter? = nil
  @@logger : Logger? = nil
  @@debug = false

  def self.debug=(value)
    @@debug = value
  end

  def self.debug?
    @@debug
  end

  def self.has_feature?(name)
    !!ENV["MSTRAP_FEAT_#{name.upcase}"]?
  end

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

  def self.logger
    @@logger ||= if debug?
      log_file = File.new(MStrap::Paths::LOG_FILE, "a+")
      writer = IO::MultiWriter.new(log_file, STDOUT)
      Logger.new(writer, level: Logger::DEBUG, formatter: log_formatter)
    else
      file = File.new(MStrap::Paths::LOG_FILE, "a+")
      Logger.new(file, level: Logger::INFO, formatter: log_formatter)
    end.not_nil!
  end
end
