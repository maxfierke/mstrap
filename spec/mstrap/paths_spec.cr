require "../spec_helper"

Spectator.describe MStrap::Paths do
  MSTRAP_TEST_RC_DIR = File.join(MSTRAP_TEST_HOME, ".mstrap")

  describe "RC_DIR" do
    it "must be relative to the home directory" do
      expect(MStrap::Paths::RC_DIR).to eq(MSTRAP_TEST_RC_DIR)
    end
  end

  describe "SRC_DIR" do
    it "must be relative to the home directory" do
      expect(MStrap::Paths::SRC_DIR).to eq(File.join(MSTRAP_TEST_HOME, "src"))
    end
  end

  describe "XDG_CONFIG_DIR" do
    it "must be relative to the home directory" do
      expect(MStrap::Paths::XDG_CONFIG_DIR).to eq(File.join(MSTRAP_TEST_HOME, ".config"))
    end
  end

  describe "BREWFILE" do
    it "must be relative to the runtime config directory" do
      expect(MStrap::Paths::BREWFILE).to eq(File.join(MSTRAP_TEST_RC_DIR, "Brewfile"))
    end
  end

  describe "CA_CERT_BUNDLE" do
    it "must be relative to the runtime config directory" do
      expect(MStrap::Paths::CA_CERT_BUNDLE).to eq(File.join(MSTRAP_TEST_RC_DIR, "cacert.pem"))
    end
  end

  describe "CONFIG_HCL" do
    it "must be relative to the runtime config directory" do
      expect(MStrap::Paths::CONFIG_HCL).to eq(File.join(MSTRAP_TEST_RC_DIR, "config.hcl"))
    end
  end

  describe "LOG_FILE" do
    it "must be relative to the runtime config directory" do
      expect(MStrap::Paths::LOG_FILE).to eq(File.join(MSTRAP_TEST_RC_DIR, "mstrap.log"))
    end
  end

  describe "PROFILES_DIR" do
    it "must be relative to the runtime config directory" do
      expect(MStrap::Paths::PROFILES_DIR).to eq(File.join(MSTRAP_TEST_RC_DIR, "profiles"))
    end
  end

  describe "PROJECT_CERTS" do
    it "must be relative to the runtime config directory" do
      expect(MStrap::Paths::PROJECT_CERTS).to eq(File.join(MSTRAP_TEST_RC_DIR, "project-certs"))
    end
  end

  describe "PROJECT_SITES" do
    it "must be relative to the runtime config directory" do
      expect(MStrap::Paths::PROJECT_SITES).to eq(File.join(MSTRAP_TEST_RC_DIR, "project-sites"))
    end
  end

  describe "PROJECT_SOCKETS" do
    it "must be relative to the project-sites directory" do
      expect(MStrap::Paths::PROJECT_SOCKETS).to eq(File.join(MStrap::Paths::PROJECT_SITES, "sockets"))
    end
  end

  describe "SERVICES_YML" do
    it "must be relative to the runtime config directory" do
      expect(MStrap::Paths::SERVICES_YML).to eq(File.join(MSTRAP_TEST_RC_DIR, "services.yml"))
    end
  end

  describe "STRAP_SH_PATH" do
    it "must be relative to the vendor directory" do
      expect(MStrap::Paths::STRAP_SH_PATH).to eq(File.join(MSTRAP_TEST_RC_DIR, "vendor", "strap.sh"))
    end
  end

  describe "STRAP_SH_URL" do
    it "must be the raw URL to fetch strap.sh" do
      {% if flag?(:darwin) %}
        expect(
          MStrap::Paths::STRAP_SH_URL
        ).to eq("https://raw.githubusercontent.com/MikeMcQuaid/strap/master/bin/strap.sh")
      {% elsif flag?(:linux) %}
        expect(
          MStrap::Paths::STRAP_SH_URL
        ).to eq("https://raw.githubusercontent.com/maxfierke/strap-linux/master/bin/strap.sh")
      {% else %}
        {{ raise "Unsupported platform" }}
      {% end %}
    end
  end
end
