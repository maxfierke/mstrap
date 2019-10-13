module MStrap
  class ProfileFetcher
    class ProfileFetchError < Exception; end
    class InvalidProfileUrlError < ProfileFetchError; end

    include Utils::System

    getter :config, :profile_dir, :profile_file_path
    getter? :force

    def initialize(config : Defs::ProfileConfigDef, force = false)
      @config = config
      @force = force
      @profile_dir = File.join(Paths::PROFILES_DIR, config.name)
      @profile_file_path = File.join(profile_dir, "profile.yml")
    end

    def fetch!
      if File.exists?(profile_file_path) && !should_update?
        config.path = profile_file_path
        return self
      end

      url = URI.parse(config.url.not_nil!)
      url.normalize!

      if url.scheme == "file"
        url = url.resolve(Paths::RC_DIR)

        if File.file?(url.path)
          ensure_profile_dir
          FileUtils.ln_s(url.path, profile_file_path)
        elsif File.directory?(url.path)
          FileUtils.ln_s(url.path, profile_dir)
        else
          raise InvalidProfileUrlError.new(
            "#{config.name}: #{url.path} does not exist or is not accessible."
          )
        end
      elsif git_url?(url)
        unless cmd("git", "clone", url.to_s, profile_dir, quiet: true)
          raise ProfileFetchError.new(
            "#{config.name}: Could not clone profile via git. Ensure you have access."
          )
        end
      elsif url.scheme == "https"
        ensure_profile_dir
        HTTP::Client.get(url) do |response|
          File.write(profile_file_path, response.body_io.gets_to_end, perm: 0o600)
        end
      else
        raise InvalidProfileUrlError.new(
          "#{config.name}: '#{url.scheme}' is not a supported scheme"
        )
      end

      config.path = profile_file_path
      config.url = url.to_s

      self
    end

    private def ensure_profile_dir
      Dir.mkdir_p(profile_dir, mode: 0o500)
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
