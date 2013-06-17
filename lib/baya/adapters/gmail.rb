module Baya
  module Adapters
    class Gmail

      require 'net/imap'

      IMAP_SERVER = "imap.gmail.com"
      IMAP_PORT = 993
      IMAP_SSL = true

      def initialize(config)
        @config = config
      end

      def archive(root)
        root = root + '/' + @config['destination']
        mkdir(root)

        imap = Net::IMAP.new(IMAP_SERVER,
          :port => IMAP_PORT,
          :ssl => IMAP_SSL
        )

        imap.login(@config['email'], @config['password'])

        all_folder = nil
        imap.list("", "*").each do |folder|
          if folder.attr.include?(:All)
            all_folder ||= folder
          end
        end

        imap.examine(all_folder.name)

        imap.search(["ALL"]).each_slice(1000) do |message_ids|
          imap.fetch(message_ids, "UID").each do |uid|
            folder = root + '/' + uid_range(uid.attr["UID"].to_i)
            mkdir(folder)

            destination = folder + '/' + uid.attr["UID"].to_s
            unless File.exists?(destination)
              content = imap.fetch(uid.seqno, "RFC822").first
              File.open(destination, 'w') do |f|
                f.write(content.attr['RFC822'])
              end
            end
          end
        end
      end

      def uid_range(n, range_size=10000)
        low = 0
        while n > low + range_size
          low += range_size
        end
        "#{low}-#{low + range_size - 1}"
      end

      def mkdir(folder)
        unless File.directory?(folder)
          FileUtils.mkdir_p(folder)
        end
      end

    end
  end
end
