{% skip_file unless flag?(:linux) %}

require "./linux/debian"
require "./linux/rhel"
require "./linux/*"

module MStrap
  module Linux
    extend self

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

    # Returns distro name
    def distro
      `lsb_release -si`.strip.downcase
    end

    # Returns distro family
    def distro_family
      d = distro

      if DEBIAN_DISTROS.includes?(d)
        DISTRO_FAMILY_DEBIAN
      elsif RHEL_DISTROS.includes?(d)
        DISTRO_FAMILY_RHEL
      else
        DISTRO_UNKNOWN
      end
    end

    # Returns distro version
    def distro_version
      `lsb_release -sr`.strip.downcase
    end

    # Returns distro version codename
    def distro_codename
      `lsb_release -sc`.strip.downcase
    end

    # Returns true if on CentOS
    def centos?
      distro == DISTRO_CENTOS
    end

    # Returns true if on Debian
    def debian?
      distro == DISTRO_DEBIAN
    end

    # Returns true of on a distro in the Debian family (e.g. Debian, Ubuntu)
    def debian_distro?
      distro_family == DISTRO_FAMILY_DEBIAN
    end

    # Returns true on Fedora
    def fedora?
      distro == DISTRO_FEDORA
    end

    # Returns true on RHEL (RedHat Enterprise Linux)
    def rhel?
      distro == DISTRO_REDHAT
    end

    # Returns true on a RHEL-based distro (e.g. RHEL, CentOS, Fedora)
    def rhel_distro?
      distro_family == DISTRO_FAMILY_RHEL
    end

    # Returns true on Ubuntu
    def ubuntu?
      distro == DISTRO_UBUNTU
    end

    # Returns true if distro is not known to mstrap
    def unknown_distro?
      distro_family == DISTRO_UNKNOWN
    end

    # :nodoc:
    def platform
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
  end
end
