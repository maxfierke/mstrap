module MStrap
  module Defs
    class ProfileConfigDef < Def
      @[HCL::Label]
      property name : String

      @[HCL::Attribute]
      property revision : String? = nil

      @[HCL::Attribute]
      property url : String

      def_equals_and_hash @name, @revision, @url, @dir

      def initialize(@name, @url, @revision = nil)
      end

      def merge!(other : self)
        self.name = other.name
        self.path = other.path if other.path
        self.revision = other.revision if other.revision
        self.url = other.url if other.url
      end

      def dir
        @dir ||= File.join(Paths::PROFILES_DIR, name)
      end

      def path
        @path ||= File.join(dir, "profile.hcl")
      end
    end

    class DefaultProfileConfigDef < ProfileConfigDef
      def initialize
        @name = "default"
        @url = ""
      end

      def name
        "default"
      end

      def dir
        Paths::RC_DIR
      end
    end
  end
end
