unless defined?(RACK_ENV)
  RACK_ENV =  ENV['RACK_ENV'] || 'development'
end

APP_ROOT = File.expand_path('../../', __FILE__)

require 'rubygems'
require 'bundler'

Bundler.require(:default)
$LOAD_PATH.unshift("#{APP_ROOT}/lib")

Dir["#{APP_ROOT}/lib/*.rb"].each { |file| require file }
Dir["#{APP_ROOT}/lib/**/*.rb"].each { |file| require file }
