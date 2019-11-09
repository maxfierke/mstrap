require 'spec_helper'

describe "dependencies step" do
  describe "git" do
    it "is installed" do
      expect(`git --version`.chomp).to match(/git version 2\./)
    end

    it "is configued for the mstrap user" do
      config_path = File.expand_path("~/.mstrap/config.yml")
      config_yaml = File.read(config_path)
      config = YAML.load(config_yaml)

      expect(`git config --global user.name`.chomp).to eq(config["user"]["name"])
      expect(`git config --global user.email`.chomp).to eq(config["user"]["email"])
      expect(`git config --global github.user`.chomp).to eq(config["user"]["github"])
    end
  end

  describe "hub" do
    it "is installed" do
      expect(`hub --version`.chomp).to match(/hub version/)
    end

    it "is configured for the mstrap user" do
      config_path = File.expand_path("~/.mstrap/config.yml")
      config_yaml = File.read(config_path)
      config = YAML.load(config_yaml)

      hub_path = File.expand_path("~/.config/hub")
      hub_yaml = File.read(hub_path)
      hub = YAML.load(hub_yaml)

      user_config = hub["github.com"].detect do |user|
        user["user"] == config["user"]["github"]
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
      'bison@2.7',
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
      'libiconv',
      'libpng',
      'libxslt',
      'libyaml',
      'openssl',
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
  end

  describe "launchdns", :if => os[:family] == 'darwin' do
    describe service('homebrew.mxcl.launchdns') do
      it { is_expected.to be_enabled }
    end
  end
end
