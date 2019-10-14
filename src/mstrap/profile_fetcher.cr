module MStrap
  class ProfileFetcher
    class ProfileFetchError < Exception; end
    class InvalidProfileUrlError < ProfileFetchError; end

    include Utils::System

    getter :config
    getter? :force

    def initialize(config : Defs::ProfileConfigDef, force = false)
      @config = config
      @force = force
    end

    def fetch!
      if File.exists?(config.path) && !should_update?
        return self
      end

      url = URI.parse(config.url)
      url.normalize!

      if url.scheme == "file"
        url = url.resolve(Paths::RC_DIR)

        if File.file?(url.path)
          ensure_profile_dir
          FileUtils.ln_s(url.path, config.path)
        elsif File.directory?(url.path)
          FileUtils.ln_s(url.path, config.dir)
        else
          raise InvalidProfileUrlError.new(
            "#{config.name}: #{url.path} does not exist or is not accessible."
          )
        end
      elsif git_url?(url)
        unless cmd("git", "clone", url.to_s, config.dir, quiet: true)
          raise ProfileFetchError.new(
            "#{config.name}: Could not clone profile via git. Ensure you have access."
          )
        end
      elsif url.scheme == "https"
        ensure_profile_dir
        HTTP::Client.get(url) do |response|
          File.write(config.path, response.body_io.gets_to_end, perm: 0o600)
        end
      else
        raise InvalidProfileUrlError.new(
          "#{config.name}: '#{url.scheme}' is not a supported scheme"
        )
      end

      self
    end

    private def ensure_profile_dir
      Dir.mkdir_p(config.dir, mode: 0o500)
    end

    private def git_url?(url)
      url.scheme == "git" ||
        url.scheme == "ssh" ||
        (!url.scheme || url.scheme == "https") && url.path.ends_with?(".git")
    end

    private def should_update?
      force? || outdated_revision?
    end

    private def outdated_revision?
      # TODO: Implement
      false
    end
  end
end
