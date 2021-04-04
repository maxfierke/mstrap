module MStrap
  module Defs
    class RuntimeDef < Def
      @[HCL::Label]
      property name : String

      @[HCL::Attribute]
      property default_version : String? = nil

      @[HCL::Block(key: "package")]
      property packages = [] of ::MStrap::Defs::PkgDef

      def_equals_and_hash @name, @default_version, @packages

      def merge!(other : self)
        if other.default_version
          self.default_version = other.default_version
        end

        other.packages.each do |pkg|
          if existing_pkg = self.packages.find { |g| g.name == pkg.name }
            existing_pkg.merge!(pkg)
          else
            self.packages << pkg
          end
        end
      end
    end
  end
end
