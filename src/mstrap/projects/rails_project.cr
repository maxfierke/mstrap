module MStrap
  module Projects
    class RailsProject < WebProject
      include Utils::Rbenv

      def bootstrap
        with_project_ruby { super }
      end
    end
  end
end
