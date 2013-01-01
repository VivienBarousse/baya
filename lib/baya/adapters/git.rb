require 'git'

module Baya
  module Adapters
    class Git

      def initialize(config)
        @config = config
        check_config
      end

      def archive(root)
        destination = root + '/' + @config['destination']
        if File.directory?(destination)
          begin
            g = ::Git.open(destination)
            g.pull
          rescue ArgumentError => e
            raise "Folder exists and is not a Git repository: #{destination}"
          end
        else
          ::Git.clone(@config['origin'], destination)
        end
      end

      private

      def check_config
        raise "`origin` is mandatory" unless @config['origin']
        raise "`destination` is mandatory" unless @config['destination']
      end

    end
  end
end
