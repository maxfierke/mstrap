module MStrap
  # Manages the fetching of strap.sh (or strap-linux.sh)
  class StrapShInstaller
    include DSL

    getter? :force

    def initialize(@force = false)
    end

    def install!
      fetch_strap_sh if update_strap_sh?
    end

    private def fetch_strap_sh
      log "--> Fetching latest strap.sh (older than 30 days, missing, or requested): "
      Dir.mkdir_p(File.join(Paths::RC_DIR, "vendor"))

      HTTP::Client.get(Paths::STRAP_SH_URL, tls: MStrap.tls_client) do |response|
        File.write(Paths::STRAP_SH_PATH, response.body_io.gets_to_end)
      end

      success "OK"
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
  end
end
