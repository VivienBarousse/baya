module Baya
  class Runner

    def initialize(config)
      @config = config
    end

    def run
      @config.adapters.each do |a|
        if klass = Adapters.from_name(a.type)
          adapter = klass.new(a.config)
        else
          raise "Unknown adapter `#{a.type}`" unless adapter
        end

        case a.mode
        when 'archive'
          adapter.archive(@config.root)
        when 'backup'
          adapter.backup(@config.root)
        else
          raise "Unknown mode `#{a.mode}` for adapter `#{a.type}`"
        end
      end
    end

  end
end
