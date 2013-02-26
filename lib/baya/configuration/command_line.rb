
module Baya
  module Configuration
    require 'optparse'
    require 'ostruct'

    class CommandLine < OpenStruct

      DEFAULTS = {
        'config' => 'baya.json'
      }

      def initialize(args)
        super()
        DEFAULTS.each do |k, v|
          self.send(:"#{k}=", v)
        end
        opts.parse(args)
      end

      def opts
        @opts ||= OptionParser.new do |opts|
          opts.on("-c", "--config CONFIG",
                  "Set path to the configuration file") do |config|
            self.config = config
          end
          opts.on_tail("-v", "--version", "Show version") do
            self.version = true
          end
          opts.on_tail("-h", "--help", "Show help") do
            self.help = true
          end
        end
      end

    end
  end
end
