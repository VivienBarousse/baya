module Baya
  module Configuration
    class File
      require 'yajl'

      class AdapterConfig

        def initialize(hash)
          @hash = hash
        end

        def type
          @hash['type']
        end

        def mode
          @hash['mode']
        end

        def config
          @hash['config']
        end

      end

      def initialize(file)
        json = ::File.open(file).read
        @data = Yajl::Parser.parse(json)
      end

      def root
        @root ||= ::File.expand_path(@data['root'])
      end

      def adapters
        (@data['adapters'] || []).map do |a|
          AdapterConfig.new(a)
        end
      end

    end
  end
end
