require 'httparty'

module EconDataReader
  class Nasdaq
    # Get data for the given name from the Bank of Canada.

    include HTTParty
    base_uri 'https://data.nasdaq.com/api/v3'
    format :json
    # debug_output $stdout

    attr_reader :tag
    attr_reader :api_key

    def self.configure
      yield self
      true
    end

    class << self
      attr_accessor :nasdaq_api_key
    end

    def initialize(series, options={})
      @api_key = options[:nasdaq_api_key] || EconDataReader::Nasdaq.nasdaq_api_key
      @tag = series
    end

    def fetch(start: nil, fin: nil)
      dta = observations({  }).parsed_response
      trans_dta = dta.transpose
      df = Polars::DataFrame.new({})

      s = trans_dta[0][1..-1].dup 
      s.map!{|t| t.to_date }
      df['Timestamps'] = Polars::Series.new(s)
      
      (1..trans_dta.length-1).to_a.each do |i|
        s = trans_dta[i][1..-1].dup
        s.map!{|t| t.to_f }
        df[dta[0][i]] = Polars::Series.new(s)
      end

      Polars::Config.set_tbl_cols(-1)
      Polars::Config.set_tbl_rows(-1)
      df
    end



    protected

    def self.default_options
      { api_key: @api_key }
    end

    delegate :default_options, to: :class

    private

    def observations(options={})
      # self.class.debug_output $stdout 
      self.class.get("https://data.nasdaq.com/api/v3/datasets/#{tag}/data.csv", body: self.default_options.merge(options).merge({ 'Content-Type' => 'application/json' }))
    end

  end
end
