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

    private def update_strap_sh?
      if File.exists?(MStrap::Paths::STRAP_SH_PATH)
        strap_sh_age.days >= 30 || force?
      else
        true
      end
    end

    private def strap_sh_age
      if file_info = File.info?(MStrap::Paths::STRAP_SH_PATH)
        Time.now - file_info.modification_time
      else
        Time::Span.zero
      end
    end

    private def force?
      !!options[:force]?
    end

    private def create_rc_dir
      FileUtils.mkdir_p(MStrap::Paths::RC_DIR, 0o755)
    end

    private def fetch_strap_sh
      if update_strap_sh?
        logw "---> Fetching latest strap.sh (older than 30 days or missing): "
        FileUtils.mkdir_p("#{MStrap::Paths::RC_DIR}/vendor")

        HTTP::Client.get(MStrap::Paths::STRAP_SH_URL) do |response|
          File.write(MStrap::Paths::STRAP_SH_PATH, response.body_io.gets_to_end)
        end
      end
    end

    private def create_brewfile_unless_exists
      if !File.exists?(MStrap::Paths::BREWFILE) || force?
        logw "---> No Brewfile found or update requested with --force. Copying default to #{MStrap::Paths::BREWFILE}: "
        brewfile_contents = FS.get("Brewfile").gets_to_end
        File.write(MStrap::Paths::BREWFILE, brewfile_contents)
        success "OK"
      end
    end
  end
end
