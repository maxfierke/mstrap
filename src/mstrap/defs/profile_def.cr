module MStrap
  module Defs
    class ProfileDef < Def
      YAML.mapping(
        package_globals: {
          type: GlobalPkgDef,
          nilable: false,
          default: GlobalPkgDef.new
        },
        projects: {
          type: Array(ProjectDef),
          nilable: false,
          default: [] of ProjectDef
        }
      )

      def initialize
        @package_globals = GlobalPkgDef.new
        @projects = [] of ProjectDef
      end

      def merge!(other : self)
        other.projects.each do |proj|
          if existing_project = self.projects.find { |pr| pr.cname == proj.cname }
            # TODO: Do something?
          else
            self.projects << proj
          end
        end

        self.package_globals.merge!(other.package_globals)
      end
    end
  end
end
