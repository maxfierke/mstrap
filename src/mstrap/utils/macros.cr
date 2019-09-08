module MStrap
  module Utils
    macro define_language_env(module_name, language_name, plugin_name)
      module {{module_name}}
        def setup_{{language_name.id}}
          cmd "asdf plugin-add {{plugin_name.id}} || echo 'Already added {{language_name.id}}'"

          with_project_{{language_name.id}} do
            cmd "asdf install {{plugin_name.id}} #{{{language_name.id}}_version}"

            {% if language_name.id == "node" %}
              if File.exists?("yarn.lock")
                cmd "brew install yarn"
                cmd "yarn install"
              elsif File.exists?("package.json")
                cmd "npm install"
              end
            {% elsif language_name.id == "ruby" %}
              cmd "gem install bundler -v '<2'"
              cmd "gem install bundler"
              cmd "bundle install" if File.exists?('Gemfile')
            {% elsif language_name.id == "python" %}
              if File.exists?("requirements.txt")
                cmd "pip install -r requirements.txt"
              end
            {% end %}
          end
        end

        def {{language_name.id}}_version
          version_path = File.join(path, ".{{language_name.id}}-version")
          version = if File.exists?(version_path)
            File.read(version_path).chomp
          else
            ENV["ASDF_{{plugin_name.id.upcase}}_VERSION"]?
          end
        end

        def with_project_{{language_name.id}}
          current_version = ENV["ASDF_{{plugin_name.id.upcase}}_VERSION"]?
          begin
            ENV["ASDF_{{plugin_name.id.upcase}}_VERSION"] = {{language_name.id}}_version
            yield
          ensure
            ENV["ASDF_{{plugin_name.id.upcase}}_VERSION"] = current_version
          end
        end
      end
    end
  end
end
