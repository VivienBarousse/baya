module Baya
  module Binaries
    class Baya

      require ROOT + '/baya/configuration/command_line'
      require ROOT + '/baya/configuration/file'
      require ROOT + '/baya/runner'

      def initialize(args)
        @args = Configuration::CommandLine.new(args)
      end

      def run
        if @args.version
          out.puts "Baya v#{VERSION}"
          return
        end
        if @args.help
          out.puts @args.opts.help
          return
        end

        unless File.file?(@args.config)
          err.puts "Can't read configuration file '#{@args.config}'."
          err.puts "Make sure it exists and it is a file."
          return
        end

        @config = Configuration::File.new(@args.config)

        runner = Runner.new(@config)
        runner.run
      end

      def out
        STDOUT
      end

      def err
        STDERR
      end

    end
  end
end
