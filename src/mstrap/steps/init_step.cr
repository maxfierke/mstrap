module MStrap
  class InitStep < Step
    include Utils::Logging
    include Utils::System

    def self.requires_mstrap?
      false
    end

    def bootstrap
      create_rc_dir
      fetch_strap_sh
      create_brewfile_unless_exists
    end

    private def force?
      !!options[:force]
    end

    private def create_rc_dir
      FileUtils.mkdir_p(MStrap::Paths::RC_DIR, 0o755)
    end

    private def fetch_strap_sh
      unless File.exists?(MStrap::Paths::STRAP_SH_PATH) || force?
        FileUtils.mkdir_p("#{MStrap::Paths::RC_DIR}/vendor")

        HTTP::Client.get(MStrap::Paths::STRAP_SH_URL) do |response|
          File.write(MStrap::Paths::STRAP_SH_PATH, response.body_io.gets_to_end)
        end
      end
    end

    private def create_brewfile_unless_exists
      unless File.exists?(MStrap::Paths::BREWFILE) || force?
        logw "---> No Brewfile found. Copying default to #{MStrap::Paths::BREWFILE}: "
        brewfile_contents = FS.get("Brewfile").gets_to_end
        File.write(MStrap::Paths::BREWFILE, brewfile_contents)
        success "OK"
      end
    end
  end
end
