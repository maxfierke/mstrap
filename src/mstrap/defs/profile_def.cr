module MStrap
  module Defs
    class ProfileDef < Def
      YAML.mapping(
        runtimes: {
          type: Hash(String, RuntimeDef),
          nilable: false,
          default: {} of String => RuntimeDef
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
        @runtimes = {} of String => RuntimeDef
        @projects = [] of ProjectDef
        @version = "1.0"
      end

      def merge!(other : self)
        other.runtimes.each do |key, value|
          if self.runtimes.has_key?(key)
            self.runtimes[key].merge!(value)
          else
            self.runtimes[key] = value
          end
        end

        other.projects.each do |proj|
          if existing_project = self.projects.find { |pr| pr.cname == proj.cname }
            existing_project.merge!(proj)
          else
            self.projects << proj
          end
        end
      end
    end
  end
end
