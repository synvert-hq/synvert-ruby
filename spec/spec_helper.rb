$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'synvert'
require 'webmock/rspec'

require 'coveralls'
Coveralls.wear!

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'
end
