module MStrap
  abstract class Runtime
    include Utils::Env
    include Utils::Logging
    include Utils::System

    # Bootstrap the current directory for the runtime
    abstract def bootstrap

    # Installs global packages for the runtime with an optional version
    # specification, and optional runtime version.
    #
    # NOTE: The version specification is dependent upon the underlying package
    # manager and is passed verbatim.
    abstract def install_packages(packages : Array(Defs::PkgDef), runtime_version : String? = nil) : Bool

    # Returns whether the project uses the runtime
    abstract def matches? : Bool

    macro finished
      # :nodoc:
      def self.all
        @@runtimes ||= [
          {% for subclass in @type.subclasses %}
            {{ subclass.name }}.new,
          {% end %}
        ]
      end
    end
  end
end
