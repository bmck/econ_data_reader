# require 'rubygems'
# gem 'httparty'
# require 'httparty'

require "econ_data_reader/version"
require 'econ_data_reader/bank_of_canada'
require 'econ_data_reader/bls'
require 'econ_data_reader/fred'
require 'econ_data_reader/nasdaq'

directory = File.expand_path(File.dirname(__FILE__))


# create config/initializers/econ_data_reader.rb
#
# EconDataReader.configure do |config|
#   config.fred_api_key = 'api_key'
# end
# client = EconDataReader::Client.new
#
# or
#
# EconDataReader.fred_api_key = 'api_key'
#
# or
#
# EconDataReader::Fred.new(:fred_api_key => 'api_key')


module EconDataReader
  class Error < StandardError; end
  # Your code goes here...
  
end
