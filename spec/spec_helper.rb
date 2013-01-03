require 'simplecov'

SimpleCov.start if ENV['COVERAGE']

ROOT = File.expand_path('../../lib', __FILE__)

require ROOT + '/baya'
