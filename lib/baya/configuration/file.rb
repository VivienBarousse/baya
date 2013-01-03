module Baya
  module Configuration
    class File
      require 'yajl'
      require 'ostruct'

      def initialize(file)
        json = ::File.open(file).read
        @data = Yajl::Parser.parse(json)
      end

      def root
        @root ||= ::File.expand_path(@data['root'])
      end

      def adapters
        (@data['adapters'] || []).map do |a|
          adapter = OpenStruct.new
          adapter.type = a["type"]
          adapter.mode = a["mode"]
          adapter.config = a["config"]
          adapter
        end
      end

    end
  end
end
