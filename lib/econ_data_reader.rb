
require "econ_data_reader/version"
require 'econ_data_reader/bank_of_canada'
require 'econ_data_reader/bls'
require 'econ_data_reader/fred'
require 'econ_data_reader/nasdaq'
require 'econ_data_reader/sahm'

directory = File.expand_path(File.dirname(__FILE__))


# create config/initializers/econ_data_reader.rb
# 
# EconDataReader::Fred.configure do |config|
#   config.fred_api_key = '1234567890ABCDEF'
#     OR
#   config.fred_api_key = File.read(File.join('','home', 'user', '.fred_api_key.txt'), 16)
# end

# EconDataReader::Bls.configure do |config|
#   config.bls_api_key = '8675309-1111-1111-ABCD'
# end

# EconDataReader::Nasdaq.configure do |config|
#   config.nasdaq_api_key = 'YOUR_API_KEY_HERE'
# end


module EconDataReader
  class Error < StandardError; end
  # Your code goes here...
  
end
