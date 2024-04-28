module MStrap
  # Manages the install of rustup for managing Rust
  #
  # NOTE: See `MStrap::RuntimeManagers::Rustup` for how rustup is integrated
  class RustupInstaller
    include DSL

    # :nodoc:
    RUSTUP_INIT_SH_PATH = File.join(MStrap::Paths::RC_DIR, "vendor", "rustup-init.sh")

    # :nodoc:
    RUSTUP_INIT_SH_URL = "https://sh.rustup.rs"

    # :nodoc:
    RUSTUP_BIN_DIR_PATH = File.join(ENV["HOME"], ".cargo", "bin")

    def install!
      fetch_installer!

      install_args = [RUSTUP_INIT_SH_PATH, "--no-modify-path"]

      if MStrap.debug?
        install_args << "--verbose"
      else
        install_args << "--quiet"
        install_args << "-y"
      end

      unless cmd "sh", install_args
        logc "Failed to install rustup"
      end

      # "Activate" it
      path = ENV["PATH"]
      ENV["PATH"] = "#{RUSTUP_BIN_DIR_PATH}:#{path}"
    end

    def installed?
      has_command?("rustup")
    end

    private def fetch_installer!
      HTTP::Client.get(RUSTUP_INIT_SH_URL, tls: MStrap.tls_client) do |response|
        File.write(RUSTUP_INIT_SH_PATH, response.body_io.gets_to_end)
      end
    end
  end
end
