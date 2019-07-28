module MStrap
  module Steps
    class NodeStep < Step
      include Utils::Logging
      include Utils::System

      @node_versions : Array(String)?
      @packages : Array(Defs::NpmPkgDef)?

      def self.description
        "Set default global Node version and installs NPM globals"
      end

      def bootstrap
        logn "==> Bootstrapping Node"
        set_default_to_latest
        install_npm_globals
      end

      private def packages
        @packages ||= profile.package_globals.npm.not_nil!
      end

      private def set_default_to_latest
        latest_node = node_versions.last
        logn "---> Setting default Node version to latest: "
        log "Setting default node version to #{latest_node}: "
        unless cmd "nodenv global #{latest_node}", quiet: true
          logc "Could not set global node version to #{latest_node}"
        end
        success "OK"
      end

      private def install_npm_globals
        return if packages.empty?

        logn "---> Installing NPM globals for installed Node versions: "
        node_versions.each do |version|
          package_names = packages.map(&.name)
          log "Installing #{package_names.join(", ")} for Node #{version}: "
          nodenv_env = { "NODENV_VERSION" => version }
          nodenv_args = ["exec", "npm", "install", "-g"] + package_names
          unless cmd(nodenv_env, "nodenv", nodenv_args, quiet: true)
            logc "Could not install NPM global packages for #{version}"
          end
          success "OK"
        end
      end

      private def node_versions
        @node_versions ||= `nodenv versions --bare 2>&1`.chomp.split("\n").not_nil!
      end
    end
  end
end
