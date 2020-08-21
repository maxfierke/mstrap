{% skip_file unless flag?(:linux) %}

module MStrap
  module Linux
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

    def self.distro
      @@distro ||= `lsb_release -si`.strip.downcase
    end

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

    def self.distro_version
      @@distro_version ||= `lsb_release -sr`.strip.downcase
    end

    def self.distro_codename
      @@distro_codename ||= `lsb_release -sc`.strip.downcase
    end

    def self.centos?
      distro == DISTRO_CENTOS
    end

    def self.debian?
      distro == DISTRO_DEBIAN
    end

    def self.debian_distro?
      distro_family == DISTRO_FAMILY_DEBIAN
    end

    def self.fedora?
      distro == DISTRO_FEDORA
    end

    def self.rhel?
      distro == DISTRO_REDHAT
    end

    def self.rhel_distro?
      distro_family == DISTRO_FAMILY_RHEL
    end

    def self.ubuntu?
      distro == DISTRO_UBUNTU
    end

    def self.unknown_distro?
      distro_family == DISTRO_UNKNOWN
    end
  end
end
