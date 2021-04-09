module MStrap
  class ProfileFetcher
    # Exception class to indicate some failure fetching a profile
    class ProfileFetchError < Exception; end

    # Exception class to indicate an invalid URL for a profile
    class InvalidProfileUrlError < ProfileFetchError; end

    # Exception class for Git-related profile fetch errors
    class GitProfileFetchError < ProfileFetchError
      def initialize(config)
        super("#{config.name}: Could not clone profile via git. Ensure you have access.")
      end
    end

    class ProfileChecksumMismatchError < ProfileFetchError
      def initialize(config)
        super("#{config.name}: Could not fetch profile due to checksum mismatch. The remote contents may have changed. Please verify and update `revision` with latest checksum.")
      end
    end

    include DSL

    @url : URI

    # Profile configuration definition
    getter :config

    # Returns normalized URL for profile
    getter :url

    # Returns whether to force profile update
    getter? :force

    def initialize(config : Defs::ProfileConfigDef, force = false)
      @config = config
      @force = force

      url = URI.parse(config.url)
      url.normalize!
      @url = url
    end

    # Fetch or update the profile
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
        CACertInstaller.install!

        begin
          tmp_file = File.tempfile

          HTTP::Client.get(url, tls: MStrap.tls_client) do |response|
            File.write(tmp_file.path, response.body_io.gets_to_end, perm: 0o600)
          end

          revision = config.revision

          if !revision || revision_checksum_valid?(tmp_file.path, revision)
            tmp_file.rewind
            File.write(config.path, tmp_file.gets_to_end, perm: 0o600)

            if !revision
              logw "Security warning: You did not specify a `revision` with the checksum for remote profile '#{config.name}'. This can be unsafe if you do not trust the source."
            end
          else
            raise ProfileChecksumMismatchError.new(config)
          end
        ensure
          tmp_file.delete if tmp_file
        end
      else
        raise InvalidProfileUrlError.new(
          "#{config.name}: '#{url.scheme}' is not a supported scheme"
        )
      end

      self
    end

    # Returns whether the profile's URL is a Git URL
    def git_url?
      @_git_url ||= url.scheme == "git" ||
                    url.scheme == "ssh" ||
                    (!url.scheme || url.scheme == "https") && url.path.ends_with?(".git")
    end

    # Returns whether the profile's URL is an HTTP URL (that is not also a Git URL)
    def https_url?
      @_https_url ||= url.scheme == "https" && !url.path.ends_with?(".git")
    end

    # Returns whether the profile is outdated.
    #
    # * For git profiles, this is based on whether the checked out Git ref
    #   differs from that of the ref recorded for `revision` in the configuration.
    # * For HTTPS profiles, this is based on the checksum recorded for `revision`
    #   in the configuration.
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
        revision_checksum_valid?(config.path, revision)
      else
        false
      end
    end

    # Returns whether to update the profile
    def should_update?
      force? || outdated_revision?
    end

    private def revision_checksum_valid?(file_path, revision)
      algo, hsh = revision.split(":")
      digester = OpenSSL::Digest.new(algo.upcase)
      digester.file(file_path).final.hexstring != hsh
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
          unless cmd("git", "pull", quiet: true)
            raise GitProfileFetchError.new(config)
          end
        end
      end
    end
  end
end
