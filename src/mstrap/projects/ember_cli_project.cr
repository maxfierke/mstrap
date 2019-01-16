module MStrap
  module Projects
    class EmberCLIProject < Project
      getter :port

      def initialize(project_config = {} of String => String | Int32)
        super(project_config)
        @port = project_config["port"].as(Int32)
      end

      def nginx_upstream
        @nginx_upstream ||= "localhost:#{port}"
      end
    end
  end
end
