module Baya
  VERSION = '0.1.0'

  ROOT = File.expand_path('..', __FILE__)
  require ROOT + "/baya/adapters"
  require ROOT + "/baya/binaries"
end
