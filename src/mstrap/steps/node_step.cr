module MStrap
  module Steps
    # Runnable as `mstrap node`, the Node step sets the default global Node.js
    # version to the latest installed and installs any global NPM packages
    # specified by any loaded profiles.
    class NodeStep < Step
      include Utils::Env
      include Utils::Logging
      include Utils::System

      @node_versions : Array(String)?
      @packages : Array(Defs::NpmPkgDef)?

      def self.description
        "Set default global Node version and installs global NPM packages"
      end

      def bootstrap
        return if node_versions.empty?
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
        unless cmd "asdf global nodejs #{latest_node}", quiet: true
          logc "Could not set global node version to #{latest_node}"
        end
        success "OK"
      end

      private def install_npm_globals
        return if packages.empty?

        logn "---> Installing NPM package globals for installed Node versions: "
        node_versions.each do |version|
          package_names = packages.map(&.name)
          log "Installing #{package_names.join(", ")} for Node #{version}: "
          nodenv_env = { "ASDF_NODEJS_VERSION" => version }
          nodenv_args = ["exec", "npm", "install", "-g"] + package_names
          unless cmd(nodenv_env, "asdf", nodenv_args, quiet: true)
            logc "Could not install global NPM packages for #{version}"
          end
          success "OK"
        end
      end

      private def node_versions
        @node_versions ||= `asdf list nodejs 2>&1`.
          chomp.
          split("\n").
          map(&.strip).
          reject(&.blank?).
          not_nil!
      end
    end
  end
end
