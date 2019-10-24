module MStrap
  module Utils
    module Logging
      # Logs a message, without appending a newline.
      def log(msg)
        return logn(msg) if debug?
        print msg
        logger.info(msg)
      end

      # Logs a message, appending a newline.
      def logn(msg)
        puts msg
        logger.info(msg)
      end

      # Logs a success message at the INFO level. On a TTY, this will output in
      # green.
      def success(msg)
        puts msg.colorize(:green)
        logger.info(msg)
      end

      # Log a message at the DEBUG level. This will only be logged when `mstrap`
      # is in debug mode.
      def logd(msg)
        logger.debug(msg)
      end

      # Logs a message at the WARN level. On a TTY, this will output in yellow.
      def logw(msg)
        puts "! #{msg}".colorize(:yellow)
        logger.warn(msg)
      end

      # Logs a message at the FATAL level and terminate program. On a TTY, this
      # will output in red. In debug, this will also print the stacktrace.
      def logc(msg)
        logger.fatal(msg)
        if debug?
          abort msg.colorize(:red)
        else
          puts "!!! #{msg}".colorize(:red)
          puts "!!! Check #{MStrap::Paths::LOG_FILE} and/or run with --debug for more detail."
          exit 1
        end
      end
    end
  end
end
