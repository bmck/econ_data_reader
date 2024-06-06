module EconDataReader
  class Fred 
    # Get data for the given name from the St. Louis FED (FRED).

    include HTTParty
    base_uri "https://api.stlouisfed.org/fred"
    format :xml

    attr_reader :tag

    def self.configure
      yield self
      true
    end

    class << self
      attr_accessor :fred_api_key
    end

    def initialize(series, options={})
      @api_key = options[:fred_api_key] || EconDataReader::Fred.fred_api_key
      @tag = series
    end

    def fetch(start: nil, fin: nil)
      dta = (series('observations', series_id: tag))['observations']['observation']
      dta.map!{|d| {'date' => d['date'].to_date, 'value' => d['value'].to_f} }

      start = start.to_s.try(:to_date)
      fin = fin.to_s.try(:to_date)
      dta.select!{|d| d['date'] >= start } unless start.nil?
      dta.select!{|d| d['date'] <= fin } unless fin.nil?

      dates = dta.map{|d| d['date'] }
      vals = dta.map{|d| d['value'] }
      Polars::Config.set_tbl_rows(-1)
      Polars::DataFrame.new({Timestamps: dates, Values: vals})
    end

    # def self.list_series
    #   dta = (get('/lists/series/json').parsed_response)['series']

    #   series = dta.keys
    #   desc = series.map{|s| [dta[s]['label'], dta[s]['description']].join('; ') }

    #   Polars::Config.set_tbl_rows(-1)
    #   Polars::DataFrame.new({Series: series, Description: desc})
    # end    

    protected

    def default_options
      {:api_key => @api_key}
    end

    private

    def category(secondary, options={})
      self.class.get((secondary.nil? ? "/category" : "/category/#{secondary}"), :query => options.merge(self.default_options))
    end

    def releases(secondary, options={})
      self.class.get((secondary.nil? ? "/releases" : "/releases/#{secondary}"), :query => options.merge(self.default_options))
    end

    def release(secondary, options={})
      self.class.get((secondary.nil? ? "/release" : "/release/#{secondary}"), :query => options.merge(self.default_options))
    end

    def series(secondary, options={})
      self.class.get((secondary.nil? ? "/series" : "/series/#{secondary}"), :query => options.merge(self.default_options))
    end

    def sources(secondary, options={})
      self.class.get((secondary.nil? ? "/sources?" : "/sources/#{secondary}"), :query => options.merge(self.default_options))
    end

    def source(secondary, options={})
      self.class.get((secondary.nil? ? "/source" : "/source/#{secondary}"), :query => options.merge(self.default_options))
    end

  end
end
