require 'spec_helper'

describe "shell step" do
  let(:rc_dir) { File.expand_path("~/.mstrap") }

  it "creates env.sh w/ expected perms" do
    env_sh_path = File.join(rc_dir, "env.sh")
    expect(File.exist?(env_sh_path)).to eq(true)
    env_sh_stat = File.stat(env_sh_path)
    expect(env_sh_stat.mode & 07777).to eq(0600)
  end

  it "correctly injects it into the shell so that env vars are available" do
    expect(ENV['MSTRAP']).to eq('true')
    expect(ENV['MSTRAP_SRC_DIR']).to eq(File.expand_path("~/src"))
    expect(ENV['MSTRAP_RC_DIR']).to eq(rc_dir)
    expect(ENV['MSTRAP_PROJECT_SOCKETS']).to eq(File.join(rc_dir, "project-sites", "sockets"))
  end
end
