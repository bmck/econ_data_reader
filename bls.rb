module EconDataReader
  class Bls
    # Get data for the given name from the Bank of Canada.

    include HTTParty
    base_uri "https://api.bls.gov/publicAPI/v2/timeseries/data"
    format :json
    # debug_output $stdout

    attr_reader :tag

    def self.configure
      yield self
      true
    end

    class << self
      attr_accessor :bls_api_key
    end

    def initialize(series, options={})
      @api_key = options[:bls_api_key] || EconDataReader::Bls.bls_api_key
      @tag = series
    end

    def fetch(start: nil, fin: nil)
      dta = observations({ seriesid: ["\"#{tag}\""] })
      Rails.logger.info { "#{__FILE__}:#{__LINE__} dta = #{dta.inspect}" }
      dta = dta.parsed_response['Results']['series'].first['data']
      Rails.logger.info { "#{__FILE__}:#{__LINE__} dta = #{dta.inspect}" }

      dates = []
      dta.each do |d|
        if d['period'][0] == 'M'
          dates << "#{d['year']}-#{d['period'][1..-1]}-01".to_date.end_of_month
        elsif d['period'][0] == 'Q'
          dates << "#{d['year']}-#{d['period'][1..-1]*3}-01".to_date.end_of_month
        end
      end
      dates = dates.map{|d| d.to_date }.select{|d| start.nil? ? true : d >= start }.select{|d| fin.nil? ? true : d <= fin }
      vals = dta.map{|d| d['value'].to_f }

      Polars::DataFrame.new({Timestamps: dates, Values: vals})
    end

    def self.list_series(options = {})
      # options = default_options.merge(options).merge({method: 'GETDATASETLIST'})
      # Rails.logger.info { "#{__FILE__}:#{__LINE__} options = #{options.inspect}"}
      # dta = get('https://apps.bea.gov/api/data/', :query => options)
      # Rails.logger.info { "#{__FILE__}:#{__LINE__} dta = #{dta.inspect}"}
      # dta = dta.parsed_response

      # dta = dta['BEAAPI']['Results']['Dataset']

      # series = dta.map{|d| d['DatasetName']}
      # desc = dta.map{|d| d['DatasetDescription']}

      # Polars::Config.set_tbl_rows(-1)
      # Polars::DataFrame.new({Series: series, Description: desc})
    end

    protected

    def self.default_options
      { registrationkey: bls_api_key }
    end

    delegate :default_options, to: :class

    private

    def observations(options={})
      # self.class.debug_output $stdout 
      self.class.post("https://api.bls.gov/publicAPI/v2/timeseries/data/#{tag}", body: self.default_options.merge(options).merge({ 'Content-Type' => 'application/json' }))
    end

  end
end
