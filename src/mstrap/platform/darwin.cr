{% skip_file unless flag?(:darwin) %}

require "./darwin/macos"

module MStrap
  module Darwin
    extend self

    def has_git?
      ENV["MSTRAP_IGNORE_GIT"]? != "true" && platform.has_git?
    end

    # :nodoc:
    def platform
      Darwin::MacOS
    end
  end
end
