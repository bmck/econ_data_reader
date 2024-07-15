require 'httparty'

module EconDataReader
  class BankOfCanada
    # Get data for the given name from the Bank of Canada.

    include ::HTTParty
    base_uri "https://www.bankofcanada.ca/valet"
    format :json

    attr_reader :tag

    def initialize(series, options={})
      @tag = series
    end

    def fetch(start: nil, fin: nil)
      dta = observations({}).parsed_response['observations']
      dta = dta.select{|d| start.nil? ? true : d['d'].to_date >= start.to_date }.select{|d| fin.nil? ? true : d['d'].to_date <= fin.to_date }

      dates = dta.map{|d| d['d'].to_date }
      vals = dta.map{|d| d[tag]['v'].to_f }

      Polars::DataFrame.new({Timestamps: dates, Values: vals})
    end

    def self.list_series
      dta = (get('/lists/series/json').parsed_response)['series']

      series = dta.keys
      desc = series.map{|s| [dta[s]['label'], dta[s]['description']].join('; ') }

      Polars::Config.set_tbl_rows(-1)
      Polars::DataFrame.new({Series: series, Description: desc})
    end

    protected

    def default_options
      { }
    end

    private

    def observations(options={})
      self.class.get("/observations/#{tag}/json", :query => options.merge(self.default_options))
    end

  end
end
