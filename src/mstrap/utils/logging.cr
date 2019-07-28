module MStrap
  module Utils
    module Logging
      include Env

      def log(msg)
        return logn(msg) if debug?
        print msg
        logger.info(msg)
      end

      def logn(msg)
        puts msg
        logger.info(msg)
      end

      def success(msg)
        puts msg.colorize(:green)
        logger.info(msg)
      end

      def logd(msg)
        logger.debug(msg)
      end

      def logw(msg)
        puts msg.colorize(:yellow)
        logger.warn(msg)
      end

      def logc(msg)
        logger.fatal(msg)
        if debug?
          abort msg.colorize(:red)
        else
          puts msg.colorize(:red)
          exit 1
        end
      end
    end
  end
end
