require 'spec_helper'

describe "dependencies step" do
  describe "git" do
    it "is installed" do
      expect(`git --version`.chomp).to match(/git version 2\./)
    end

    it "is configued for the mstrap user" do
      config_path = File.expand_path("~/.mstrap/config.hcl")
      config_hcl = File.read(config_path)

      git_name = `git config --global user.name`.chomp
      git_email = `git config --global user.email`.chomp
      git_github = `git config --global github.user`.chomp

      expect(config_hcl).to match(/name = "#{git_name}"/)
      expect(config_hcl).to match(/email = "#{git_email}"/)
      expect(config_hcl).to match(/github = "#{git_github}"/)
    end
  end

  describe "default Brewfile packages" do
    PACKAGES = [
      'ack',
      'asdf',
      'autoconf',
      'automake',
      'bash-completion',
      'bison',
      'coreutils',
      'curl',
      'findutils',
      'gettext',
      'git',
      'gnu-sed',
      'gnu-tar',
      'jpeg',
      'jq',
      'libpng',
      'mkcert',
      'nss',
      'openssl@1.1',
      'pkg-config',
      'readline',
      'unixodbc',
      'zlib',
    ].freeze

    PACKAGES.each do |pkg|
      describe package(pkg) do
        it { is_expected.to be_installed.by('homebrew') }
      end
    end

    describe "darwin packages", if: os[:family] == 'darwin' do
      DARWIN_PACKAGES = [
        'libiconv',
        'nss',
      ].freeze

      DARWIN_PACKAGES.each do |pkg|
        describe package(pkg) do
          it { is_expected.to be_installed.by('homebrew') }
        end
      end
    end
  end

  describe "launchdns", :if => os[:family] == 'darwin' do
    describe service('homebrew.mxcl.launchdns') do
      it { is_expected.to be_enabled }
    end
  end
end
