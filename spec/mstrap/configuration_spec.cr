require "../spec_helper"

def write_config_to_disk(config_def, config_path)
  config_hcl = config_def.to_hcl
  FileUtils.mkdir_p(MStrap::Paths::RC_DIR, 0o755)
  File.write(config_path, config_hcl, perm: 0o600)
end

def write_profile_to_disk(name, profile_def)
  profile_hcl = profile_def.to_hcl

  profile_path = if name == "default"
                   MStrap::Paths::RC_DIR
                 else
                   "#{MStrap::Paths::PROFILES_DIR}/#{name}"
                 end

  FileUtils.mkdir_p(profile_path, 0o755)

  File.write("#{profile_path}/profile.hcl", profile_hcl, perm: 0o600)
end

def delete_config_file!
  File.delete(MStrap::Paths::CONFIG_HCL)
end

def delete_config_file
  delete_config_file! if File.exists?(MStrap::Paths::CONFIG_HCL)
end

def delete_profile(name)
  profile_path = "#{MStrap::Paths::PROFILES_DIR}/#{name}"
  FileUtils.rm_rf(profile_path)
end

Spectator.describe MStrap::Configuration do
  let(config_def) do
    MStrap::Defs::ConfigDef.from_hcl(<<-HCL)
      version = "1.0"

      user {
        name = "Reginald Testington"
        email = "reginald@testington.biz"
      }

      profile "personal" {
        url = "ssh://git@gitprovider.biz/reggiemctest/mstrap-personal.git"
      }

    HCL
  end

  let(personal_profile_def) do
    MStrap::Defs::ProfileDef.from_hcl(<<-HCL)
      version = "1.0"

      project "test" {
        name = "testing a thing"
        repo = "https://github.com/maxfierke/testing-a-thing.git"
      }

      runtime "ruby" {
        package "brakeman" {}
      }

    HCL
  end

  before_each do
    delete_config_file
  end

  after_each do
    delete_config_file
  end

  describe "#load_profiles!" do
    subject { MStrap::Configuration.new(config_def) }

    context "there are loaded profiles" do
      it "returns without doing anything" do
        profile_config = MStrap::Defs::DefaultProfileConfigDef.new
        subject.loaded_profile_configs << profile_config
        subject.loaded_profile_configs << MStrap::Defs::ProfileConfigDef.new("test", "https://my.test.git.biz")
        subject.loaded_profiles << MStrap::Defs::ProfileDef.new

        subject.load_profiles!

        expect(subject.loaded_profiles?).to be_true
        expect(subject.profile_configs.size).to eq(2)
        expect(subject.profile_configs.first).to eq(profile_config)
        expect(subject.profiles.size).to eq(1)
      end
    end

    context "there are no loaded profiles" do
      mock MStrap::ProfileFetcher do
        stub fetch! { nil }
      end

      after_each do
        delete_profile("personal")
        File.delete("#{MStrap::Paths::RC_DIR}/profile.hcl") if File.exists?("#{MStrap::Paths::RC_DIR}/profile.hcl")
      end

      let(local_profile_def) do
        MStrap::Defs::ProfileDef.from_hcl(<<-HCL)
          version = "1.0"

          project "secret-project" {
            name = "secret area 51"
            repo = "https://github.com/maxfierke/secret-thing.git"
            port = 4555
          }

          runtime "ruby" {
            package "aws-sdk-core" {}
            package "aws-sdk-s3" {}
          }

        HCL
      end

      it "loads configs and populates resolved_profile" do
        write_profile_to_disk("default", local_profile_def)
        write_profile_to_disk("personal", personal_profile_def)

        expect {
          subject.load_profiles!
        }.not_to raise_error

        expect(subject.loaded_profiles?).to be_true
        expect(subject.profile_configs.size).to eq(2)
        expect(subject.profile_configs.first.name).to eq("personal")

        expect(subject.resolved_profile.version).to eq("1.0")

        test_proj = MStrap::Defs::ProjectDef.new
        test_proj.cname = "test"
        test_proj.name = "testing a thing"
        test_proj.repo = "https://github.com/maxfierke/testing-a-thing.git"

        secret_proj = MStrap::Defs::ProjectDef.new
        secret_proj.cname = "secret-project"
        secret_proj.name = "secret area 51"
        secret_proj.repo = "https://github.com/maxfierke/secret-thing.git"
        secret_proj.port = 4555_i64

        expect(subject.resolved_profile.projects).to eq([
          test_proj,
          secret_proj,
        ])

        runtime = subject.resolved_profile.runtimes.first
        expect(runtime.name).to eq("ruby")
        expect(runtime.packages).to eq([
          MStrap::Defs::PkgDef.new("brakeman"),
          MStrap::Defs::PkgDef.new("aws-sdk-core"),
          MStrap::Defs::PkgDef.new("aws-sdk-s3"),
        ])
      end

      context "there is no default config on disk" do
        let(config_def) do
          MStrap::Defs::ConfigDef.new(
            user: MStrap::Defs::UserDef.new(
              name: "Reginald",
              email: "Testington",
              github: nil
            ),
          )
        end

        it "loads fine anyway" do
          delete_config_file

          expect {
            subject.load_profiles!
          }.not_to raise_error

          expect(subject.profile_configs.size).to eq(1)
          expect(subject.profile_configs.first).to eq(
            MStrap::Configuration::DEFAULT_PROFILE_CONFIG_DEF
          )
        end
      end

      context "profile does not exist even after fetching for some reason" do
        it "raises an exception" do
          expect {
            subject.load_profiles!
          }.to raise_error(MStrap::Configuration::ConfigurationNotFoundError)
        end
      end

      context "not-mstrapped and git is not installed" do
        around_each do |proc|
          orig_mstrap = ENV["MSTRAP"]?
          ENV["MSTRAP"] = nil
          ENV["MSTRAP_IGNORE_GIT"] = "true"
          begin
            proc.call
          ensure
            ENV["MSTRAP"] = orig_mstrap
            ENV["MSTRAP_IGNORE_GIT"] = nil
          end
        end

        it "skips fetching and loading git profiles" do
          expect {
            subject.load_profiles!
          }.not_to raise_error

          expect(subject.profile_configs.size).to eq(1)
          expect(subject.profile_configs.first).to eq(
            MStrap::Configuration::DEFAULT_PROFILE_CONFIG_DEF
          )
        end
      end
    end
  end

  describe "#loaded_profiles?" do
    subject { MStrap::Configuration.new(config_def) }

    context "there are loaded profiles" do
      it "returns true" do
        subject.loaded_profiles << MStrap::Defs::ProfileDef.new

        expect(subject.loaded_profiles?).to be_true
      end
    end

    context "there are no loaded profiles" do
      it "returns false" do
        expect(subject.loaded_profiles?).to be_false
      end
    end
  end

  describe "#profile_configs" do
    subject { MStrap::Configuration.new(config_def) }

    context "there are loaded profile configurations" do
      it "returns the loaded profile configurations" do
        profile_config = MStrap::Defs::DefaultProfileConfigDef.new
        subject.loaded_profile_configs << profile_config

        expect(subject.profile_configs.size).to eq(1)
        expect(subject.profile_configs.first).to eq(profile_config)
      end
    end

    context "there are no loaded profile configurations" do
      it "returns an empty array" do
        expect(subject.profile_configs.size).to eq(0)
      end
    end
  end

  describe "#profiles" do
    subject { MStrap::Configuration.new(config_def) }

    context "there are loaded profiles" do
      it "returns the loaded profiles" do
        profile = MStrap::Defs::ProfileDef.new
        subject.loaded_profiles << profile

        expect(subject.profiles.size).to eq(1)
        expect(subject.profiles.first).to eq(profile)
      end
    end

    context "there are no loaded profiles" do
      it "returns an empty array" do
        expect(subject.profiles.size).to eq(0)
      end
    end
  end

  describe "#reload!" do
    context "configuration exists" do
      it "re-initializes from the config on disk" do
        subject = MStrap::Configuration.new(config_def)
        cloned_config_def = config_def.dup
        subject.loaded_profile_configs << MStrap::Configuration::DEFAULT_PROFILE_CONFIG_DEF
        subject.loaded_profile_configs << MStrap::Defs::ProfileConfigDef.new("test", "https://my.test.git.biz")
        subject.loaded_profiles << MStrap::Defs::ProfileDef.new

        cloned_config_def.user.name = "Reggie Testerton"
        cloned_config_def.user.email = "reggie@testerton.co"
        cloned_config_def.profiles.clear

        write_config_to_disk(cloned_config_def, MStrap::Paths::CONFIG_HCL)

        subject.reload!

        expect(subject.user.name).to eq("Reggie Testerton")
        expect(subject.user.email).to eq("reggie@testerton.co")
        expect(subject.loaded_profile_configs.size).to eq(1)
        expect(subject.loaded_profiles.size).to eq(0)
      end
    end

    context "configuration does not exist" do
      it "raises an exception" do
        subject = MStrap::Configuration.new(config_def)

        expect {
          subject.reload!
        }.to raise_error(MStrap::Configuration::ConfigurationNotFoundError)
      end
    end
  end

  describe "#save!" do
    it "saves the loaded configuration back to disk" do
      subject = MStrap::Configuration.new(config_def)
      expect(File.exists?(MStrap::Paths::CONFIG_HCL)).to be_false
      subject.save!
      expect(File.exists?(MStrap::Paths::CONFIG_HCL)).to be_true
      expect(File.read(MStrap::Paths::CONFIG_HCL)).to eq(config_def.to_hcl)
    end
  end
end
