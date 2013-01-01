module Baya
  module Adapters
    require ROOT + '/baya/adapters/git'
    require ROOT + '/baya/adapters/github'
    
    ADAPTERS = {
      'git' => Git,
      'github' => Github
    }

    def self.from_name(name)
      ADAPTERS[name]
    end
  end
end
