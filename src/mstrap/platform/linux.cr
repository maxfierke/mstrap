{% skip_file unless flag?(:linux) %}

module MStrap
  module Linux
    class UnsupportedDistroError < Exception; end

    DISTRO_CENTOS  = "centos"
    DISTRO_DEBIAN  = "debian"
    DISTRO_FEDORA  = "fedora"
    DISTRO_REDHAT  = "redhat"
    DISTRO_UBUNTU  = "ubuntu"
    DISTRO_UNKNOWN = "unknown"

    DEBIAN_DISTROS = [
      DISTRO_DEBIAN,
      DISTRO_UBUNTU,
    ]
    RHEL_DISTROS = [
      DISTRO_CENTOS,
      DISTRO_FEDORA,
      DISTRO_REDHAT,
    ]

    DISTRO_FAMILY_RHEL   = "rhel"
    DISTRO_FAMILY_DEBIAN = "debian"

    @@distro : String? = nil
    @@distro_codename : String? = nil
    @@distro_family : String? = nil
    @@distro_version : String? = nil

    # Returns distro name
    def self.distro
      @@distro ||= `lsb_release -si`.strip.downcase
    end

    # Returns distro family
    def self.distro_family
      @@distro_family ||= begin
        d = distro

        if DEBIAN_DISTROS.includes?(d)
          DISTRO_FAMILY_DEBIAN
        elsif RHEL_DISTROS.includes?(d)
          DISTRO_FAMILY_RHEL
        else
          DISTRO_UNKNOWN
        end
      end
    end

    # Returns distro version
    def self.distro_version
      @@distro_version ||= `lsb_release -sr`.strip.downcase
    end

    # Returns distro version codename
    def self.distro_codename
      @@distro_codename ||= `lsb_release -sc`.strip.downcase
    end

    # Returns true if on CentOS
    def self.centos?
      distro == DISTRO_CENTOS
    end

    # Returns true if on Debian
    def self.debian?
      distro == DISTRO_DEBIAN
    end

    # Returns true of on a distro in the Debian family (e.g. Debian, Ubuntu)
    def self.debian_distro?
      distro_family == DISTRO_FAMILY_DEBIAN
    end

    # Returns true on Fedora
    def self.fedora?
      distro == DISTRO_FEDORA
    end

    # Returns true on RHEL (RedHat Enterprise Linux)
    def self.rhel?
      distro == DISTRO_REDHAT
    end

    # Returns true on a RHEL-based distro (e.g. RHEL, CentOS, Fedora)
    def self.rhel_distro?
      distro_family == DISTRO_FAMILY_RHEL
    end

    # Returns true on Ubuntu
    def self.ubuntu?
      distro == DISTRO_UBUNTU
    end

    # Returns true if distro is not known to mstrap
    def self.unknown_distro?
      distro_family == DISTRO_UNKNOWN
    end

    # :nodoc:
    def self.platform
      if debian_distro?
        Linux::Debian
      elsif fedora?
        Linux::Fedora
      elsif rhel_distro?
        Linux::RHEL
      else
        raise UnsupportedDistroError.new
      end
    end

    # Installs a list of packages using the distro's package manager
    def self.install_packages!(packages : Array(String))
      platform.install_packages!(packages)
    end

    # Installs a single package using the distro's package manager
    def self.install_package!(package_name : String)
      platform.install_packages!([package_name])
    end

    # Install a single package using the distro's package manager
    def self.package_installed?(package_name : String)
      platform.package_installed?(package_name)
    end
  end
end
