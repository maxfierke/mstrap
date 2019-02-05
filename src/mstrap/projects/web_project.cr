module MStrap
  module Projects
    class WebProject < Project
      @hostname : String

      getter :hostname, :port

      def initialize(project_config = {} of String => String | Int32)
        super(project_config)
        @hostname = project_config["hostname"].as(String?) || "#{cname}.localhost"
        @port = project_config["port"]?.as(Int32)
        @nginx_upstream = project_config["upstream"]?.as(String?)
      end

      def nginx_upstream
        @nginx_upstream ||= begin
          if port = @port
            "localhost:#{port}"
          else
            "unix:#{MStrap::Paths::PROJECT_SOCKETS}/#{cname}"
          end
        end
      end
    end
  end
end
