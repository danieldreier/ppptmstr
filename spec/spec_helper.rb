require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
require 'coveralls'
Coveralls.wear!

ENV['RACK_ENV'] = 'test'

#support_path = File.expand_path('../../features/support', __FILE__)
app_path = File.expand_path('../..', __FILE__)

require          'json_spec/helpers'
require          'rack/test'
require_relative '../ppptmstr'
#require_relative support_path + '/factories'
#require_relative support_path + '/helpers'

#Dir["./spec/support/**/*.rb"].sort.each { |f| require f}

# Disable SQL logging unless environment variable log is set to true
#ActiveRecord::Base.logger.level = 1 unless ENV['LOG'] == 'true'

RSpec.configure do |config|
  config.include JsonSpec::Helpers
  config.include Rack::Test::Methods

#  config.before(:suite) do 
#    DatabaseCleaner.strategy = :transaction
#    DatabaseCleaner.clean_with(:truncation)
#  end

#  config.around(:each) do |example|
#    DatabaseCleaner.start
#    example.run
#    DatabaseCleaner.clean
#  end

end

def app
  Canto
end
