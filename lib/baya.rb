module Baya
  VERSION = '0.1.2'

  ROOT = File.expand_path('..', __FILE__)
  require ROOT + "/baya/adapters"
  require ROOT + "/baya/binaries"
end
