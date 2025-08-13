module MStrap
  class DNSMasq
    include DSL

    # :nodoc:
    CONFIG_BLOCK = <<-CFG
    # BEGIN MSTRAP
    address=/localhost/127.0.0.1
    # END MSTRAP
    CFG

    # :nodoc:
    CONFIG_PATH = File.join(MStrap::Paths::HOMEBREW_PREFIX, "etc", "dnsmasq.conf")

    # :nodoc:
    RESOLVER_CONFIG_PATH = "/etc/resolver/localhost"

    # Returns whether dnsmasq is installed
    def installed?
      has_command?("dnsmasq") && config_installed? && resolver_installed?
    end

    # Runs dnsmasq install process and adds resolver for .localhost
    def install!
      remove_launchdns!
      install_dnsmasq!
      install_dnsmasq_config!
      install_resolver!
    end

    private def config_installed? : Bool
      File.exists?(CONFIG_PATH) && File.read(CONFIG_PATH).includes?(CONFIG_BLOCK)
    end

    private def resolver_installed? : Bool
      File.exists?(RESOLVER_CONFIG_PATH)
    end

    private def remove_launchdns! : Nil
      return unless has_command?("launchdns")

      logn "==> Found launchdns. Removing..."

      log "===> Remove .localhost resolver config:"
      if File.exists?(RESOLVER_CONFIG_PATH)
        unless cmd("rm", "-f", RESOLVER_CONFIG_PATH, sudo: true)
          logc "An error occurred while removing #{RESOLVER_CONFIG_PATH}"
        end
      end
      success "OK"

      log "===> Uninstalling launchdns:"
      MStrap::Platform.uninstall_packages!(["launchdns"])
      success "OK"
    end

    private def install_dnsmasq! : Nil
      return if has_command?("dnsmasq")
      log "==> Installing dnsmasq:"
      MStrap::Platform.install_packages!(["dnsmasq"])
      success "OK"
    end

    private def install_dnsmasq_config! : Nil
      return if config_installed?

      unless File.exists?(CONFIG_PATH)
        logc "dnsmasq config doesn't exist at #{CONFIG_PATH}"
      end

      log "==> Updating dnsmasq config to resolve *.localhost: "
      File.open(CONFIG_PATH, "a") do |config_file|
        config_file.puts CONFIG_BLOCK
      end
      success "OK"
      log "==> Restarting dnsmasq: "
      unless cmd("brew services restart dnsmasq", quiet: true, sudo: true)
        logc "An error occurred while restarting dnsmasq. Did you have a prior configuration that conflicts?"
      end
      success "OK"
    end

    private def install_resolver! : Nil
      unless cmd("mkdir", "-p", "/etc/resolver", sudo: true)
        logc "An error occurred while creating /etc/resolver"
      end

      unless cmd("touch #{RESOLVER_CONFIG_PATH}", sudo: true)
        logc "An error occurred while creating #{RESOLVER_CONFIG_PATH}"
      end

      unless cmd("echo nameserver 127.0.0.1 | sudo tee -a #{RESOLVER_CONFIG_PATH}")
        logc "An error occurred while writing #{RESOLVER_CONFIG_PATH}"
      end
    end
  end
end
