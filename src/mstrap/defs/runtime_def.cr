module MStrap
  module Defs
    class RuntimeDef < Def
      @[HCL::Label]
      property name : String

      @[HCL::Attribute]
      property default_version : String? = nil

      @[HCL::Block(key: "package")]
      property packages = Hash(String, MStrap::Defs::PkgDef).new

      def_equals_and_hash @name, @default_version, @packages

      def merge!(other : self)
        if other.default_version
          self.default_version = other.default_version
        end

        other.packages.each do |pkg_name, pkg|
          if existing_pkg = self.packages[pkg_name]?
            existing_pkg.merge!(pkg)
          else
            self.packages[pkg_name] = pkg
          end
        end
      end
    end
  end
end
