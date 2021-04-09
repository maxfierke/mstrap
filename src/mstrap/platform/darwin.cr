{% skip_file unless flag?(:darwin) %}

module MStrap
  module Darwin
    def self.platform
      Darwin::MacOS
    end
  end
end
