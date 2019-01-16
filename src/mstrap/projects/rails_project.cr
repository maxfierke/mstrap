module MStrap
  module Projects
    class RailsProject < Project
      include Utils::Rbenv

      def nginx_upstream
        @nginx_upstream ||= "unix:#{MStrap::Paths::PROJECT_SOCKETS}/#{cname}"
      end

      def bootstrap
        with_project_ruby { super }
      end
    end
  end
end
