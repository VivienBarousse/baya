module Baya
  module Adapters
    class Github

      require 'curb'
      require 'yajl'
      require ROOT + "/baya/adapters/git"

      API_ROOT = "https://api.github.com/"

      def initialize(config)
        @config = config
        check_config
      end

      def archive(root)
        repos.each do |url|
          name = url.split('/').last.gsub(/\.git$/, "")
          git = Git.new('origin' => url, 'destination' => name)
          git.archive(root + '/' + @config['destination'])
        end
      end

      def repos
        api_url = API_ROOT + target
        http = Curl.get(api_url)
        json = http.body_str
        data = Yajl::Parser.parse(json)
        data.map do |repo|
          repo['clone_url']
        end
      end

      private

      def target
        if @config['user']
          "users/#{@config['user']}/repos"
        elsif @config['org']
          "orgs/#{@config['org']}/repos"
        else
          raise "`user` or `org` is required"
        end
      end

      def check_config
        unless @config["user"] or @config["org"]
          raise "`user` or `org` is required"
        end
        if @config['user'] and @config['org']
          raise "`user` and `org` are exclusive"
        end
        raise "`destination` is required" unless @config['destination']
      end

    end
  end
end
