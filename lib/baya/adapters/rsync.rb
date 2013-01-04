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

      def backup(root)
        target = root + "/" + @config['destination']
        source = @config['source']
        date = Time.now.strftime("%Y%m%d%H%M%S")

        previous = Dir[target + "/*/"].sort_by { |a| File.basename(a) }

        rsync_backup(source, target + "/" + date, previous.last)

        if keep = @config['keepBackups'] && @config['keepBackups'].to_i
          if previous.count - keep > 0
            to_delete = previous[0..previous.count - keep]
            to_delete.each do |f|
              FileUtils.rmtree(f)
            end
          end
        end
      end

      private

      def rsync_archive(source, target)
        check_folder(target, "destination")
        options = "-az"
        options += 'v' if @config['verbose']
        Open3.popen3("rsync", options, source, target) do |i, o, e, process|
          process && process.value

          o.each_line do |l|
            STDOUT.puts "rsync: #{l}"
          end
          e.each_line do |l|
            STDERR.puts "rsync: #{l}"
          end

          if process && process.value != 0
            raise "Non-zero value from `rsync`."
          end
        end
      end

      def rsync_backup(source, target, link)
        check_folder(target, "destination")
        options = [
          "rsync",
          "-az",
          "--delete",
          source,
          target
        ]
        options << "--link-dest=#{link}" if link
        options << "-v" if @config['verbose']

        Open3.popen3(*options) do |i, o, e, process|
          process && process.value

          o.each_line do |l|
            STDOUT.puts "rsync: #{l}"
          end
          e.each_line do |l|
            STDERR.puts "rsync: #{l}"
          end

          if process && process.value != 0
            raise "Non-zero value from `rsync`."
          end
        end
      end

      def check_folder(dir, name)
        if File.exist?(dir) && !File.directory?(dir)
          raise "`#{name}` already exists, and is not a directory"
        end
        unless File.exist?(dir)
          FileUtils.mkdir_p(dir)
        end
      end

    end
  end
end
