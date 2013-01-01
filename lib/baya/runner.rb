module Baya
  class Runner

    def initialize(config)
      @config = config
    end

    def run
      adapters = @config.adapters.each do |a|
        adapter = Adapters.from_name(a.type).new(a.config)
        case a.mode
        when 'archive'
          adapter.archive(@config.root)
        else
          raise "Unknown mode `#{a.mode}` for adapter `#{a.type}`"
        end
      end
    end

  end
end
