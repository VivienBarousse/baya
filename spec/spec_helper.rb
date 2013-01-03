if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

ROOT = File.expand_path('../../lib', __FILE__)

require ROOT + '/baya'
