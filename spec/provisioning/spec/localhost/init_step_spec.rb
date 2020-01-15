require 'spec_helper'

describe "init step" do
  let(:rc_dir) { File.expand_path("~/.mstrap") }

  it "creates the runtime config directory w/ expected perms" do
    expect(Dir.exist?(rc_dir)).to eq(true)
    dir_stat = File.stat(rc_dir)
    expect(dir_stat.mode & 07777).to eq(0755)
  end

  it "ensures a config file exists w/ expected perms" do
    config_path = File.join(rc_dir, "config.hcl")
    expect(File.exist?(config_path)).to eq(true)
    config_stat = File.stat(config_path)
    expect(config_stat.mode & 07777).to eq(0600)
  end

  it "installs a cached copy of the cURL cacert.pem w/ expected perms" do
    cert_path = File.join(rc_dir, "cacert.pem")
    expect(File.exist?(cert_path)).to eq(true)
    cert_stat = File.stat(cert_path)
    expect(cert_stat.mode & 07777).to eq(0600)
  end

  it "installs a cached copy of the strap.sh script" do
    vendor_sh_path = File.join(rc_dir, "vendor", "strap.sh")
    expect(File.exist?(vendor_sh_path)).to eq(true)
  end

  it "installs a Brewfile" do
    brewfile_path = File.join(rc_dir, "Brewfile")
    expect(File.exist?(brewfile_path)).to eq(true)
  end
end
