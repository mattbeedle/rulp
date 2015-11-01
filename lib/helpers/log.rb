##
# Basic logger module.
# Allows logging in the format
#
# "This is a string".log(:debug)
# "Oh no!".log(:error)
#
# Log level is set as follows.
# Rulp::Logger::level = :debug
#
##
module Rulp
  module Logger
    DEBUG = 5
    INFO  = 4
    WARN  = 3
    ERROR = 2
    OFF   = 1

    LEVELS = {
      debug: DEBUG,
      info: INFO,
      warn: WARN,
      error: ERROR,
      off: OFF
    }

    def self.level=(value)
      raise StandardError.new("#{value} is not a valid log level") unless LEVELS[value]
      @@level = value
    end

    def self.level
      @@level || :info
    end

    def self.print_solver_outputs
      @@solver_level
    end

    def self.print_solver_outputs=(value)
      @@solver_level = value
    end

    def self.log(level, message)
      if(LEVELS[level].to_i <= LEVELS[self.level])
        puts("[#{colorize(level)}] #{message}")
      end
    end

    def self.colorize(level)
      if defined?(Pry) && Pry.color
        case level.to_sym
        when :debug
          Pry::Helpers::Text.cyan(level)
        when :info
          Pry::Helpers::Text.green(level)
        when :warn
          Pry::Helpers::Text.magenta(level)
        when :error
          Pry::Helpers::Text.red(level)
        end
      else
        level
      end
    end

    self.level = :info
    self.print_solver_outputs = true

    class ::String
      def log(level)
        Logger::log(level, self)
      end
    end

    class ::Array
      def log(level, sep="\n")
        Logger::log(level, self.join("#{sep}[#{level}] "))
      end
    end
  end
end