require 'serverspec'

# Patch in support for Linuxbrew
class Specinfra::Command::Linux::Base::Package < Specinfra::Command::Base::Package
  class << self
    def check_is_installed_by_homebrew(package, version=nil)
      escaped_package = escape(File.basename(package))
      if version
        cmd = %Q[brew info #{escaped_package} | grep -E "^$(brew --prefix)/Cellar/#{escaped_package}/#{escape(version)}"]
      else
        cmd = "#{brew_list} | grep -E '^#{escaped_package}$'"
      end
      cmd
    end

    def brew_list
      # Since `brew list` is slow, directly check Cellar directory
      'ls -1 "$(brew --prefix)/Cellar/"'
    end
  end
end

set :backend, :exec
