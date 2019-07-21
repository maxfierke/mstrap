require "baked_file_system"
require "colorize"
require "ecr"
require "file_utils"
require "http/client"
require "json"
require "option_parser"
require "readline"
require "uri"
require "yaml"

require "./mstrap/fs"
require "./mstrap/paths"
require "./mstrap/version"
require "./mstrap/utils/**"
require "./mstrap/tracker"
require "./mstrap/project"
require "./mstrap/projects/web_project"
require "./mstrap/projects/**"
require "./mstrap/templates/**"
require "./mstrap/step"
require "./mstrap/steps/**"
require "./mstrap/bootstrapper"

module MStrap
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
end
