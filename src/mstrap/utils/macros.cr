module MStrap
  module Utils
    macro define_language_env(module_name, language_name, plugin_name)
      module {{module_name}}
        def setup_{{language_name.id}}
          cmd "asdf plugin-add {{plugin_name.id}} || echo 'Already added {{language_name.id}}'"

          with_project_{{language_name.id}} do
            cmd "asdf install {{plugin_name.id}} #{{{language_name.id}}_version}"

            Dir.cd(path) do
              {% if language_name.id == "node" %}
                if File.exists?("yarn.lock")
                  cmd "brew install yarn"
                  cmd "yarn install"
                elsif File.exists?("package.json")
                  cmd "npm install"
                end
              {% elsif language_name.id == "ruby" %}
                if File.exists?("gems.rb")
                  cmd "gem install bundler"
                  cmd "bundle install"
                elsif File.exists?("Gemfile")
                  cmd "gem install bundler -v '<2'"
                  cmd "bundle install"
                end
              {% elsif language_name.id == "php" %}
                if File.exists?("composer.json")
                  cmd "brew install composer"
                  cmd "composer install"
                end
              {% elsif language_name.id == "python" %}
                if File.exists?("requirements.txt")
                  cmd "pip install -r requirements.txt"
                end
              {% end %}
            end
          end
        end

        def {{language_name.id}}?
          return true if runtime == "{{language_name.id}}"

          {% if language_name.id == "node" %}
            Dir.cd(path) do
              [
                "yarn.lock",
                "package.json",
                "npm-shrinkwrap.json",
                ".node-version"
              ].any? do |file|
                File.exists?(file)
              end
            end
          {% elsif language_name.id == "php" %}
            Dir.cd(path) do
              [
                "composer.json",
                "composer.lock",
                ".php-version"
              ].any? do |file|
                File.exists?(file)
              end
            end
          {% elsif language_name.id == "python" %}
            Dir.cd(path) do
              [
                "requirements.txt",
                ".python-version"
              ].any? do |file|
                File.exists?(file)
              end
            end
          {% elsif language_name.id == "ruby" %}
            Dir.cd(path) do
              [
                "Gemfile.lock",
                "Gemfile",
                "gems.rb",
                "gems.locked",
                ".ruby-version"
              ].any? do |file|
                File.exists?(file)
              end
            end
          {% else %}
            {{raise "Please define language detection criteria here."}}
          {% end %}
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
