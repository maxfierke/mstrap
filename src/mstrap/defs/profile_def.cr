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
        },
        version: {
          type: String,
          nilable: false,
          default: "1.0"
        }
      )

      def initialize
        @package_globals = GlobalPkgDef.new
        @projects = [] of ProjectDef
        @version = "1.0"
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
