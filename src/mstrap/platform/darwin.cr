{% skip_file unless flag?(:darwin) %}

require "./darwin/macos"

module MStrap
  module Darwin
    extend self

    # :nodoc:
    def platform
      Darwin::MacOS
    end
  end
end
