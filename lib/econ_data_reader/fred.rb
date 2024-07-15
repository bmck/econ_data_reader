require 'httparty'
require 'csv'

module EconDataReader
  class Fred
    # Get data for the given name from the St. Louis FED (FRED).
    extend ActiveSupport::Concern

    include ::HTTParty
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
      data = _read(tag)

      begin
        data = data.select{ |date, _| (start.nil? || date >= start) && (fin.nil? || date <= fin) }
      rescue KeyError => e
        if data.keys[3].to_s[7, 5] == "Error"
          raise IOError, "Failed to get the data. Check that '#{nm}' is a valid FRED series."
        else
          raise e
        end
      end

      Polars::DataFrame.new({Timestamps: data.keys, tag.to_sym => data.values})
    end

    private

    def _url; "https://fred.stlouisfed.org/graph/fredgraph.csv"; end

    def _read(symbols)
      names = Array(symbols)
      urls = names.map { |n| "#{_url}?id=#{n}" }

      data_frames = urls.zip(names).map { |url, nm| _fetch_data(url, nm) }
      Rails.logger.info { "#{__FILE__}:#{__LINE__} data_frames = #{data_frames.inspect}" }
      df = data_frames.reduce({}) { |acc, df| acc.merge(df) { |_, old_val, new_val| old_val || new_val } }
      Rails.logger.info { "#{__FILE__}:#{__LINE__} df = #{df.inspect}" }
      df
    end

    def _fetch_data(url, nm)
      # Utility to fetch data
      resp = self.class.get(url).parsed_response.map{|a| a.join(',')}.join("\n")
      Rails.logger.info { "#{__FILE__}:#{__LINE__} resp = #{resp.inspect}" }
      data = CSV.parse(resp, headers: true, header_converters: :symbol, converters: [:date, :integer])
      Rails.logger.info { "#{__FILE__}:#{__LINE__} nm = #{nm}, data = #{data.inspect}" }
      data = data.map { |row| [Date.parse(row[:date].to_s), row[data.headers.last].to_i] }.to_h
      Rails.logger.info { "#{__FILE__}:#{__LINE__} data = #{data.inspect}" }

      data
    end
  end
end
