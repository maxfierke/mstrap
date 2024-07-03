module MStrap
  # Manages the install of mise for managing language runtimes
  #
  # NOTE: See `MStrap::RuntimeManagers::Mise` for how mise is integrated
  class MiseInstaller
    include DSL

    # :nodoc:
    MISE_INSTALL_SH_PATH = File.join(MStrap::Paths::RC_DIR, "vendor", "mise_install.sh")

    # :nodoc:
    MISE_INSTALL_SH_URL = "https://mise.jdx.dev/install.sh"

    # :nodoc:
    MISE_INSTALL_SH_SIG_KEY_ID = "0x24853EC9F655CE80B48E6C3A8B81C9D17413A06D"

    # :nodoc:
    MISE_INSTALL_SH_SIG_PATH = "#{MISE_INSTALL_SH_PATH}.sig"

    # :nodoc:
    MISE_INSTALL_SH_SIG_URL = "https://mise.jdx.dev/install.sh.sig"

    # :nodoc:
    MISE_BIN_DIR_PATH = File.join(MStrap::Paths::RC_DIR, "vendor", "mise", "bin")

    # :nodoc:
    MISE_INSTALL_PATH = File.join(MISE_BIN_DIR_PATH, "mise")

    def initialize(@verify_installer : Bool? = nil)
    end

    def install!
      FileUtils.mkdir_p(MISE_BIN_DIR_PATH)

      fetch_installer!

      mise_env = {
        "MISE_INSTALL_PATH" => MISE_INSTALL_PATH,
      }

      if MStrap.verbose?
        mise_env["MISE_DEBUG"] = "1"
      else
        mise_env["MISE_QUIET"] = "1"
      end

      cmd mise_env, "sh", [MISE_INSTALL_SH_PATH]

      # "Activate" it
      path = ENV["PATH"]
      ENV["PATH"] = "#{MISE_BIN_DIR_PATH}:#{path}"
    end

    def installed?
      File.exists?(MISE_INSTALL_PATH) && has_command?("mise")
    end

    private def fetch_installer!
      if verify_installer?
        HTTP::Client.get(MISE_INSTALL_SH_SIG_URL, tls: MStrap.tls_client) do |response|
          File.write(MISE_INSTALL_SH_SIG_PATH, response.body_io.gets_to_end)
        end

        unless fetch_installer_public_key && decrypt_installer
          logc "Unable to verify mise installer. Signature does not appear to be valid."
        end
      else
        logw "Skipping validation of the mise installer (likely because gpg is not installed or was not found)"
        logw "mise will still be downloaded over HTTPS, but we cannot fully validate the authenticity of the installer"
        HTTP::Client.get(MISE_INSTALL_SH_URL, tls: MStrap.tls_client) do |response|
          File.write(MISE_INSTALL_SH_PATH, response.body_io.gets_to_end)
        end
      end
    end

    private def fetch_installer_public_key
      cmd "gpg", ["--keyserver", "hkps://keyserver.ubuntu.com", "--recv-keys", MISE_INSTALL_SH_SIG_KEY_ID], quiet: true
    end

    private def decrypt_installer
      cmd "gpg", ["-o", MISE_INSTALL_SH_PATH, "--yes", "--decrypt", MISE_INSTALL_SH_SIG_PATH], quiet: true
    end

    private def verify_installer?
      has_command?("gpg")
    end
  end
end
