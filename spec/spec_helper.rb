require 'rubygems'
require 'bundler/setup'

ROOT = File.expand_path('../..', __FILE__)
Dir[File.join(ROOT, 'spec/support/**/*.rb')].each {|f| require f}
$LOAD_PATH.unshift(File.expand_path('lib', ROOT))

require 'kraken-io'
require 'rspec/its'
require 'webmock/rspec'

RSpec.configure do |config|
  config.mock_with :rspec
end
