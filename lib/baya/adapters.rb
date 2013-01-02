module Baya
  module Adapters
    require ROOT + '/baya/adapters/git'
    require ROOT + '/baya/adapters/github'
    require ROOT + '/baya/adapters/rsync'
    
    ADAPTERS = {
      'git' => Git,
      'github' => Github,
      'rsync' => Rsync
    }

    def self.from_name(name)
      ADAPTERS[name]
    end
  end
end
