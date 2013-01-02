module Baya
  module Adapters
    class Rsync

      require 'open3'
      require 'fileutils'

      def initialize(config)
        @config = config
      end

      def archive(root)
        target = root + "/" + @config['destination']
        source = @config['source']

        rsync_archive(source, target)
      end

      private

      def rsync_archive(source, target)
        if File.exist?(target) && !File.directory?(target)
          raise "`destination` already exists, and is not a directory"
        end
        unless File.exist?(target)
          FileUtils.mkdir_p(target)
        end
        Open3.popen3("rsync", "-az", source, target) do |i, o, e, process|
          if process.value != 0
            raise "Non-zero value from `rsync`."
          end
        end
      end

    end
  end
end
