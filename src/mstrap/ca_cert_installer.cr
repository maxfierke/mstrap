module MStrap
  class CACertInstaller
    include Utils::Env
    include Utils::Logging
    include Utils::System

    def self.install!
      new.install!
    end

    def install!
      FileUtils.mkdir_p(Paths::RC_DIR, 0o755)
      Dir.cd(Paths::RC_DIR) do
        unless cmd("curl --silent --remote-name --time-cond cacert.pem https://curl.haxx.se/ca/cacert.pem")
          logc "There was an error fetching the cURL CA Cert bundle, which is needed to verify HTTPS certificates. mstrap cannot continue."
        end
      end
    end
  end
end
