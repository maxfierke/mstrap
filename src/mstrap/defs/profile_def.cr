module MStrap
  module Defs
    class ProfileDef < Def
      @[HCL::Attribute]
      property version = "1.0"

      @[HCL::Block(key: "project")]
      property projects = Hash(String, ::MStrap::Defs::ProjectDef).new

      @[HCL::Block(key: "runtime")]
      property runtimes = Hash(String, MStrap::Defs::RuntimeDef).new

      def_equals_and_hash @version, @projects, @runtimes

      def initialize
      end

      def merge!(other : self)
        other.runtimes.each do |runtime_name, runtime|
          if existing_runtime = self.runtimes[runtime_name]?
            existing_runtime.merge!(runtime)
          else
            self.runtimes[runtime_name] = runtime
          end
        end

        other.projects.each do |proj_cname, proj|
          if existing_project = self.projects[proj_cname]?
            existing_project.merge!(proj)
          else
            self.projects[proj_cname] = proj
          end
        end
      end
    end
  end
end
