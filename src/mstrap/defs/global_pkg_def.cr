module MStrap
  module Defs
    class GlobalPkgDef < Def
      YAML.mapping(
        gems: {
          type: Array(GemDef),
          nilable: false,
          default: [] of GemDef
        },
        npm: {
          type: Array(NpmPkgDef),
          nilable: false,
          default: [] of NpmPkgDef
        },
        pip: {
          type: Array(PipPkgDef),
          nilable: false,
          default: [] of PipPkgDef
        },
      )

      def initialize
        @gems = [] of GemDef
        @npm = [] of NpmPkgDef
        @pip = [] of PipPkgDef
      end

      def merge!(other : self)
        other.gems.each do |gem|
          if existing_gem = self.gems.find { |g| g.name == gem.name }
            # TODO: Figure out what to do here.
          else
            self.gems << gem
          end
        end

        other.npm.each do |pkg|
          if existing_pkg = self.npm.find { |n| n.name == pkg.name }
            # TODO: Figure out what to do here.
          else
            self.npm << pkg
          end
        end

        other.pip.each do |pkg|
          if existing_pkg = self.pip.find { |pi| pi.name == pkg.name }
            # TODO: Figure out what to do here.
          else
            self.pip << pkg
          end
        end
      end
    end
  end
end
