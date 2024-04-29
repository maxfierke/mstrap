module MStrap
  module Darwin
    module MacOS
      extend DSL

      XCODE_CLT_GIT_PATH = "/Library/Developer/CommandLineTools/usr/bin/git"

      @@git_path : String = ""

      # Indicates whether the host platform has Git installed
      #
      # NOTE: On macOS, there's a few tricks involved due to Xcode shims, so we'll only
      # consider it installed if it's from Homebrew (or elswhere),
      # accessible via `xcrun` or installed via Xcode Command Line Tools
      def self.has_git?
        git_path = @@git_path
        return true if git_path != ""

        git_path = Process.find_executable("git")

        # Ignore the Xcode CLT shim trickery!
        if git_path && git_path == "/usr/bin/git"
          # Try and look it up with xcrun
          if has_command?("xcrun")
            xcrun_git_path = `xcrun -find git 2>/dev/null`.chomp
            git_path = Process.find_executable(xcrun_git_path) if $?.success?
          end

          # Fallback to default CLT path
          git_path ||= Process.find_executable(XCODE_CLT_GIT_PATH)
        end

        return false if git_path.nil?

        @@git_path = git_path
        true
      end

      def self.install_packages!(packages : Array(String))
        cmd("brew", ["install"] + packages)
      end

      def self.package_installed?(package_name : String)
        cmd("brew list | grep -q '^#{package_name}$'", quiet: true)
      end
    end
  end
end
