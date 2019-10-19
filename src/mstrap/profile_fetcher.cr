module MStrap
  class ProfileFetcher
    class ProfileFetchError < Exception; end
    class InvalidProfileUrlError < ProfileFetchError; end
    class GitProfileFetchError < ProfileFetchError
      def initialize(config)
        super("#{config.name}: Could not clone profile via git. Ensure you have access.")
      end
    end

    include Utils::System

    getter :config, :url
    getter? :force

    def initialize(config : Defs::ProfileConfigDef, force = false)
      @config = config
      @force = force

      url = URI.parse(config.url)
      url.normalize!
      @url = url
    end

    def fetch!
      if File.exists?(config.path) && !should_update?
        return self
      end

      if url.scheme == "file"
        file_url = url.resolve(Paths::RC_DIR)

        if File.file?(file_url.path)
          ensure_profile_dir
          FileUtils.ln_s(file_url.path, config.path)
        elsif File.directory?(file_url.path)
          FileUtils.ln_s(file_url.path, config.dir)
        else
          raise InvalidProfileUrlError.new(
            "#{config.name}: #{file_url.path} does not exist or is not accessible."
          )
        end
      elsif git_url?
        if File.directory?(config.dir)
          update_profile_from_git!
        else
          git_clone_profile!(url)
        end
      elsif https_url?
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

    def git_url?
      @_git_url ||= url.scheme == "git" ||
        url.scheme == "ssh" ||
        (!url.scheme || url.scheme == "https") && url.path.ends_with?(".git")
    end

    def https_url?
      @_https_url ||= url.scheme == "https" && !url.path.ends_with?(".git")
    end

    def outdated_revision?
      revision = config.revision

      if !revision
        return nil
      end

      if git_url? && File.directory?(config.dir)
        Dir.cd(config.dir) do
          `git rev-parse HEAD`.chomp != `git rev-parse #{revision}`.chomp
        end
      elsif https_url? && File.exists?(config.path)
        algo, hsh = revision.split(":")
        digester = OpenSSL::Digest.new(algo.upcase)
        digester.file(config.path).hexdigest != hsh
      else
        false
      end
    end

    def should_update?
      force? || outdated_revision?
    end

    private def git_clone_profile!(url)
      unless cmd("git", "clone", url.to_s, config.dir, quiet: true)
        raise GitProfileFetchError.new(config)
      end

      if config.revision
        git_checkout_profile_revision!
      end
    end

    private def git_checkout_profile_revision!
      Dir.cd(config.dir) do
        unless cmd("git", "checkout", config.revision.not_nil!, quiet: true)
          ProfileFetchError.new("#{config.name}:  could not checkout revision #{config.revision}")
        end
      end
    end

    private def ensure_profile_dir
      Dir.mkdir_p(config.dir, mode: 0o500)
    end

    private def update_profile_from_git!
      Dir.cd(config.dir) do
        if config.revision
          unless cmd("git", "fetch", "origin", quiet: true)
            raise GitProfileFetchError.new(config)
          end

          git_checkout_profile_revision!
        else
          unless cmd("git", "pull", "origin", "master", quiet: true)
            raise GitProfileFetchError.new(config)
          end
        end
      end
    end
  end
end
