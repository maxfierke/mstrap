{% skip_file unless flag?(:linux) %}

module MStrap
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

  @@linux_distro : String? = nil
  @@linux_distro_codename : String? = nil
  @@linux_distro_family : String? = nil
  @@linux_distro_version : String? = nil

  def self.linux_distro
    @@linux_distro ||= `lsb_release -si`.strip.downcase
  end

  def self.linux_distro_family
    @@linux_distro_family ||= begin
      distro = linux_distro

      if DEBIAN_DISTROS.includes?(distro)
        DISTRO_FAMILY_DEBIAN
      elsif RHEL_DISTROS.includes?(distro)
        DISTRO_FAMILY_RHEL
      else
        DISTRO_UNKNOWN
      end
    end
  end

  def self.linux_distro_version
    @@linux_distro_version ||= `lsb_release -sr`.strip.downcase
  end

  def self.linux_distro_codename
    @@linux_distro_codename ||= `lsb_release -sc`.strip.downcase
  end

  def self.centos?
    linux_distro == DISTRO_CENTOS
  end

  def self.debian?
    linux_distro == DISTRO_DEBIAN
  end

  def self.debian_distro?
    linux_distro_family == DISTRO_FAMILY_DEBIAN
  end

  def self.fedora?
    linux_distro == DISTRO_FEDORA
  end

  def self.rhel?
    linux_distro == DISTRO_REDHAT
  end

  def self.rhel_distro?
    linux_distro_family == DISTRO_FAMILY_RHEL
  end

  def self.ubuntu?
    linux_distro == DISTRO_UBUNTU
  end

  def self.unknown_distro?
    linux_distro_family == DISTRO_UNKNOWN
  end
end
