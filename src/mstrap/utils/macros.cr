module MStrap
  module Utils
    # Macro for breaking out of the current ruby/node/etc. version with some ENV trickery
    # https://github.com/rbenv/rbenv/issues/904
    macro define_language_env(module_name, tool_name, language_name)
      module {{module_name}}
        def {{language_name.id}}_version
          version_path = File.join(path, ".{{language_name.id}}-version")
          version = if File.exists?(version_path)
            File.read(version_path).chomp
          else
            ENV["{{tool_name.id.upcase}}_VERSION"]?
          end
        end

        def with_project_{{language_name.id}}
          with_clean_rbenv do
            current_version = ENV["{{tool_name.id.upcase}}_VERSION"]?
            begin
              ENV["{{tool_name.id.upcase}}_VERSION"] = {{language_name.id}}_version
              yield
            ensure
              ENV["{{tool_name.id.upcase}}_VERSION"] = current_version
            end
          end
        end

        def with_clean_{{tool_name.id}}
          old_path = ENV["PATH"]
          ENV["PATH"] = ENV["PATH"].split(":").
            uniq.
            reject { |p| p.index("#{ENV["{{tool_name.id.upcase}}_ROOT"]?}/versions/") == 0 }.
            join(":")
          begin
            yield
          ensure
            ENV["PATH"] = old_path
          end
        end
      end
    end
  end
end
