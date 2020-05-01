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

  describe "hub" do
    it "is installed" do
      expect(`hub --version`.chomp).to match(/hub version/)
    end

    it "is configured for the mstrap user" do
      config_path = File.expand_path("~/.mstrap/config.hcl")
      config_hcl = File.read(config_path)
      config_user_github = config_hcl.match(/github = "(.*)"/)[1]

      hub_path = File.expand_path("~/.config/hub")
      hub_yaml = File.read(hub_path)
      hub = YAML.load(hub_yaml)

      user_config = hub["github.com"].detect do |user|
        user["user"] == config_user_github
      end

      expect(user_config).not_to be_nil
      expect(user_config["oauth_token"]).not_to be_nil
      expect(user_config["protocol"]).to eq("https")
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
      'gcc',
      'gettext',
      'git',
      'gnu-sed',
      'gnu-tar',
      'hub',
      'jpeg',
      'jq',
      'libpng',
      'libyaml',
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

    describe package('libiconv'), :if => os[:family] == 'darwin' do
      it { is_expected.to be_installed.by('homebrew') }
    end
  end

  describe "launchdns", :if => os[:family] == 'darwin' do
    describe service('homebrew.mxcl.launchdns') do
      it { is_expected.to be_enabled }
    end
  end
end
