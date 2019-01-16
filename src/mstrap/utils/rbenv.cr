# we have to break out of the current ruby version with some ENV trickery
# https://github.com/rbenv/rbenv/issues/904
module MStrap
  module Utils
    module Rbenv
      def with_project_ruby
        ruby_version_path = File.join(path, ".ruby-version")
        ruby_version = if File.exists?(ruby_version_path)
          File.read(ruby_version_path).chomp
        else
          ENV["RBENV_VERSION"]?
        end

        with_clean_rbenv do
          current_ruby_version = ENV["RBENV_VERSION"]?
          begin
            ENV["RBENV_VERSION"] = ruby_version
            yield
          ensure
            ENV["RBENV_VERSION"] = current_ruby_version
          end
        end
      end

      def with_clean_rbenv
        old_path = ENV["PATH"]
        ENV["PATH"] = ENV["PATH"].split(":").uniq.reject { |p| p.index("#{ENV["RBENV_ROOT"]?}/versions/") == 0 }.join(":")
        begin
          yield
        ensure
          ENV["PATH"] = old_path
        end
      end
    end
  end
end
