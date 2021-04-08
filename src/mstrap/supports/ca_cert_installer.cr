module MStrap
  class CACertInstaller
    include Utils::Logging
    include Utils::System

    def self.install!
      new.install!
    end

    def install!
      FileUtils.mkdir_p(Paths::RC_DIR, 0o755)
      Dir.cd(Paths::RC_DIR) do
        unless cmd("curl -L --silent --remote-name --time-cond cacert.pem https://curl.se/ca/cacert.pem")
          logc "There was an error fetching the cURL CA Cert bundle, which is needed to verify HTTPS certificates. mstrap cannot continue."
        end
        File.chmod(Paths::CA_CERT_BUNDLE, 0o600)
      end
    end
  end
end
