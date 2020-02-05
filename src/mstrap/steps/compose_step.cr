module MStrap
  module Steps
    # Runnable as `mstrap compose`, the Compose step provides a wrapper around
    # docker-compose that loads all profile's services.yml, to allow managing
    # all mstrap-managed Docker services.
    #
    # NOTE: Due to limitations with how step arguments work, any arguments
    # intended for `docker-compose` must be seperated by `--` so as to not get
    # interpretted by the `mstrap` CLI options parser. For example, using
    # `mstrap compose -- --version` to print the docker-compose version.
    class ComposeStep < Step
      include Utils::Docker
      include Utils::Env
      include Utils::Logging
      include Utils::System

      REMOVED_FLAGS = [
        "-c",
        "-d",
        "-f",
        "-h",
        "--skip-project-update"
      ]

      def self.description
        "Wrapper around `docker-compose` and all loaded profile's services.yml"
      end

      def self.setup_cmd!(cmd)
        # HACK: Remove persistent flags that overlap with docker-compose
        cmd.flags.flags.reject! do |flag|
          REMOVED_FLAGS.includes?(flag.short) || REMOVED_FLAGS.includes?(flag.long)
        end
        cmd.ignore_unmapped_flags = true
      end

      def bootstrap
        ensure_docker_compose!

        file_args = docker_compose_file_args

        if file_args.empty?
          logc "No services.yml found. Please create one at #{Paths::SERVICES_YML}, or within a profile."
        end

        compose_args = file_args + args

        logn "# mstrap: executing docker-compose #{compose_args.join(' ')}"
        Process.exec("docker-compose", compose_args)
      end
    end
  end
end
