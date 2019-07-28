{% skip_file if flag?(:release) %}
module MStrap
  module Steps
    class DebugStep < Step
      def self.description
        "Prints debug information"
      end

      def self.requires_mstrap?
        false
      end

      def bootstrap
        puts "mstrap v#{MStrap::VERSION}"
        puts "Paths:"
        puts "  RC_DIR: #{MStrap::Paths::RC_DIR}"
        puts "  SRC_DIR: #{MStrap::Paths::SRC_DIR}"
        puts "  BREWFILE: #{MStrap::Paths::BREWFILE}"
        puts "  CONFIG_YML: #{MStrap::Paths::CONFIG_YML}"
        puts "  LOG_FILE: #{MStrap::Paths::LOG_FILE}"
        puts "  PROJECT_SOCKETS: #{MStrap::Paths::PROJECT_SOCKETS}"
        puts "  SERVICES_YML: #{MStrap::Paths::SERVICES_YML}"
        puts "  STRAP_SH_PATH: #{MStrap::Paths::STRAP_SH_PATH}"
        puts "  STRAP_SH_URL: #{MStrap::Paths::STRAP_SH_URL}"
        puts "Steps:"
        pp! Step.all
      end
    end
  end
end
