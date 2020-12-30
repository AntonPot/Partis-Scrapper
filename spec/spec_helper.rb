require 'rspec'
require 'awesome_print'
require 'pry-byebug'
require 'webmock/rspec'
require_relative './../lib/getter.rb'
require_relative './../lib/runner.rb'
require_relative './../lib/scrapper.rb'

ENV['TEST'] = '1'

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.after(:all) do
    path = "#{Dir.getwd}/tmp/test_log"
    File.delete(path) if File.exist?(path)
  end
end
