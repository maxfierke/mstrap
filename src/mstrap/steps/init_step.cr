module MStrap
  class InitStep < Step
    include Utils::Logging
    include Utils::System

    def self.description
      "Initializes #{Paths::RC_DIR}"
    end

    def self.requires_mstrap?
      false
    end

    def bootstrap
      logn "==> Initializing mstrap"
      create_rc_dir
      fetch_strap_sh
      create_brewfile_unless_exists
      config.save!
    end

    private def update_strap_sh?
      if File.exists?(Paths::STRAP_SH_PATH)
        strap_sh_age.days >= 30 || force?
      else
        true
      end
    end

    private def strap_sh_age
      if file_info = File.info?(Paths::STRAP_SH_PATH)
        Time.local - file_info.modification_time
      else
        Time::Span.zero
      end
    end

    private def force?
      !!options.force?
    end

    private def create_rc_dir
      FileUtils.mkdir_p(Paths::RC_DIR, 0o755)
    end

    private def fetch_strap_sh
      if update_strap_sh?
        log "---> Fetching latest strap.sh (older than 30 days or missing): "
        FileUtils.mkdir_p("#{Paths::RC_DIR}/vendor")

        HTTP::Client.get(Paths::STRAP_SH_URL) do |response|
          File.write(Paths::STRAP_SH_PATH, response.body_io.gets_to_end)
        end

        success "OK"
      end
    end

    private def create_brewfile_unless_exists
      if !File.exists?(Paths::BREWFILE) || force?
        logw "No Brewfile found or update requested with --force"
        log "---> Copying default Brewfile to #{Paths::BREWFILE}: "
        brewfile_contents = FS.get("Brewfile").gets_to_end
        File.write(Paths::BREWFILE, brewfile_contents)
        success "OK"
      end
    end
  end
end
