module MStrap
  module Defs
    class ProfileDef < Def
      @[HCL::Attribute]
      property version = "1.0"

      @[HCL::Block(key: "project")]
      property projects = [] of ::MStrap::Defs::ProjectDef

      @[HCL::Block(key: "runtime")]
      property runtimes = [] of ::MStrap::Defs::RuntimeDef

      def initialize
      end

      def merge!(other : self)
        other.runtimes.each do |runtime|
          if existing_runtime = self.runtimes.find { |rt| rt.name == runtime.name }
            existing_runtime.merge!(runtime)
          else
            self.runtimes << runtime
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
