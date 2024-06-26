{% skip_file if flag?(:release) %}

module MStrap
  module Steps
    # Runnable as `mstrap debug`, the Debug step prints some useful debugging
    # and configuration information.
    #
    # NOTE: It is not included when `mstrap` is compiled in `release` mode.
    class DebugStep < Step
      def self.description
        "Prints debug information"
      end

      def self.requires_mstrap?
        false
      end

      def bootstrap
        puts "mstrap v#{MStrap::VERSION}"
        puts "Loaded Config:"
        puts "  #{options.config_path}"
        puts "Default runtime manager:"
        puts "  #{config.default_runtime_manager.name}"
        puts "Resolved runtime managers:"
        config.runtime_managers.each do |runtime_manager|
          puts "  #{runtime_manager.name}"
        end
        puts "Resolved runtimes:"
        config.runtimes.each do |runtime_name, runtime|
          puts "  #{runtime_name} (via #{runtime.runtime_manager.name})"
        end
        puts "Known Profiles:"
        config.known_profile_configs.each do |profile|
          puts "  #{profile.name}"
        end
        puts "Loaded Profiles:"
        config.profile_configs.each do |profile|
          puts "* #{profile.name} (#{profile.path})"
        end
        puts "Paths:"
        puts "  RC_DIR: #{MStrap::Paths::RC_DIR}"
        puts "  SRC_DIR: #{MStrap::Paths::SRC_DIR}"
        puts "  BREWFILE: #{MStrap::Paths::BREWFILE}"
        puts "  CONFIG_HCL: #{MStrap::Paths::CONFIG_HCL}"
        puts "  LOG_FILE: #{MStrap::Paths::LOG_FILE}"
        puts "  PROJECT_SOCKETS: #{MStrap::Paths::PROJECT_SOCKETS}"
        puts "  SERVICES_YML: #{MStrap::Paths::SERVICES_YML}"
        puts "  STRAP_SH_PATH: #{MStrap::Paths::STRAP_SH_PATH}"
        puts "  STRAP_SH_URL: #{MStrap::Paths::STRAP_SH_URL}"
        puts "Resolved Profile:"
        puts profile.to_hcl
        puts "Steps:"
        # ameba:disable Lint/DebugCalls
        pp! Step.all
      end
    end
  end
end
