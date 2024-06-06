# EconDataReader

Up to date remote economic data access for ruby, using Polars dataframes. 

This package will fetch economic and financial information from several different sources.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'econ_data_reader'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install econ_data_reader


### Configuration

Some data sources will require the specification of an API key.  These keys should be provided as part of a configuration file, e.g., config/econ_data_reader.rb

```ruby
EconDataReader::Fred.configure do |config|
  config.fred_api_key = '1234567890ABCDEF'
    OR
  config.fred_api_key = File.read(File.join('','home', 'user', '.fred_api_key.txt'), 16)
end

EconDataReader::Bls.configure do |config|
  config.bls_api_key = '8675309-1111-1111-ABCD'
end

EconDataReader::Nasdaq.configure do |config|
  config.nasdaq_api_key = 'YOUR_API_KEY_HERE'
end
```    

## Usage

``` ruby
EconDataReader::BankOfCanada.new('IEXE0102').fetch

EconDataReader::Fred.new('GS10').fetch 

EconDataReader::Bls.new('LNS14000006')

EconDataReader::Nasdaq.new('WIKI/AAPL').fetch
```

## Documentation

TBD

## Contributing

Others are welcome to contribute to the project.

The following conventions are intended for this project.
 * Different sources are intended to reside in different classes.  
 * API keys (if needed) should be able to be set in the single configuration file.  
 * Series should be able to be identified via a single unique string, provided in the constructor.
 * When fetched, the dataset may be filtered based on optional (hash) arguments.
 * Output should be provided in a consistent DataFrame format (currently Polars::DataFrame).

Bug reports and pull requests are welcome on GitHub at https://github.com/bmck/econ_data_reader.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
