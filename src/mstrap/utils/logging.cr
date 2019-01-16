module MStrap
  module Utils
    module Logging
      include Env

      def logf(msg)
        File.open(MStrap::Paths::LOG_FILE, mode: "a+") do |file|
          file.puts msg
        end
      end

      def log(msg)
        return logn(msg) if debug?
        print msg
        logf msg
      end

      def logn(msg)
        puts msg
        logf msg
      end

      def success(msg)
        puts msg.colorize(:green)
        logf "* #{msg}"
      end

      def logd(msg)
        logn(msg) if debug?
      end

      def logw(msg)
        puts msg.colorize(:yellow)
        logf "! #{msg}"
      end

      def logc(msg)
        logf "!!! #{msg}"
        abort msg.colorize(:red)
      end
    end
  end
end
